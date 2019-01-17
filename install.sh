#!/usr/bin/env bash

baseDir=${1:-/Applications/Slack.app}
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


if [ -f ./snippet.js ] && grep -q "$startPattern" ./snippet.js ; then
    # load snippet locally
    snippet=$(cat ./snippet.js)
else
    # load snippet remotely
    snippet=$(curl -s 'https://raw.githubusercontent.com/MashupMill/slack-themes/master/snippet.js')
fi

# strip out the existing tweak
jsWithoutTheme=$(sed -e "\\|${startPattern}|,\\|${endPattern}|d" "$jsFile")

# write out the js file without the tweak
echo "${jsWithoutTheme}" > "$jsFile"

# add the tweak to the js file
echo "${snippet}" >> "$jsFile"