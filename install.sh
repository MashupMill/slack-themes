#!/usr/bin/env bash

baseDir=${1:-/Applications/Slack.app}
DEV_MODE=${DEV_MODE:-false}
jsFile=$(find "$baseDir" -name ssb-interop.js)

if [ "$baseDir" == "-h" ] || [ "$baseDir" == "--help" ]; then
    echo "Usage $0 [/path/to/Slack.app]"
    echo ''
    echo 'If /path/to/Slack.app is not provided, then we will look in /Applications/Slack.app'
    exit
fi

if [ ! -f "$jsFile" ]; then
    echo "Could not find ssb-interop.js in ${baseDir}"
    exit 1
fi

if [ ! -w "$jsFile" ]; then
    echo "Write permission not granted to ${jsFile}. Try sudo $0 $1"
    exit 1
fi

startPattern='// START MASHUPMILL/SLACK-THEMES -- DO NOT MODIFY'
endPattern='// END MASHUPMILL/SLACK-THEMES -- DO NOT MODIFY'

cacheBuster=$(date +'%s')
if [[ $DEV_MODE == "true" ]]; then
    cacheBuster='${Date.now()}'
fi

if [ -f ./snippet.js ] && grep -q "$startPattern" ./snippet.js ; then
    # load snippet locally
    snippet=$(cat ./snippet.js | sed s/BUST_A_CACHE/$cacheBuster/g)
else
    # load snippet remotely
    snippet=$(curl -s 'https://raw.githubusercontent.com/MashupMill/slack-themes/master/snippet.js' | sed s/BUST_A_CACHE/$cacheBuster/g)
fi

# strip out the existing snippet
jsWithoutTheme=$(sed -e "\\|${startPattern}|,\\|${endPattern}|d" "$jsFile")

if [[ $DEV_MODE == "true" ]]; then
    # write out the js file without the snippet
    echo "${jsWithoutTheme}" > "$jsFile"

    # add the snippet to the js file replacing the baseurl with localhost
    echo "$snippet" | sed 's|https://raw.githubusercontent.com/MashupMill/slack-themes/master/|http://localhost:8164/|g' >> "$jsFile"

    # start up a little server
    npx http-server --cors -p 8164
fi

# write out the js file without the snippet
echo "${jsWithoutTheme}" > "$jsFile"

# add the snippet to the js file
echo "${snippet}" >> "$jsFile"
