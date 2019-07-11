#!/usr/bin/env bash

baseDir=${1:-/Applications/Slack.app}
DEV_MODE=${DEV_MODE:-false}


if [ "$baseDir" == "-h" ] || [ "$baseDir" == "--help" ]; then
    echo "Usage $0 [/path/to/Slack.app]"
    echo ''
    echo 'If /path/to/Slack.app is not provided, then we will look in /Applications/Slack.app'
    exit
fi

function patch_js_file() {
    local jsFile="${1}"
    local baseDir="${2:-/Applications/Slack.app}"
    local snippet=""
    local cacheBuster=$(date +'%s')
    local startPattern='// START MASHUPMILL/SLACK-THEMES -- DO NOT MODIFY'
    local endPattern='// END MASHUPMILL/SLACK-THEMES -- DO NOT MODIFY'

    if [ ! -f "$jsFile" ]; then
        echo "Could not find ${jsFile} in ${baseDir}"
        exit 1
    fi

    if [ ! -w "$jsFile" ]; then
        echo "Write permission not granted to ${jsFile}. Try sudo $0 $1"
        exit 1
    fi

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
    local jsWithoutTheme=$(sed -e "\\|${startPattern}|,\\|${endPattern}|d" "$jsFile")

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
}

jsFile=$(find "$baseDir" -name ssb-interop.js)
asarFile=$(find "$baseDir" -name app.asar)

if [ -f "$jsFile" ]; then
    patch_js_file "$jsFile" "$baseDir"
else
    if [ ! -f "$asarFile" ]; then
        echo "Could not find app.asar in ${baseDir}"
        exit 1
    fi

    if [ ! -f "${asarFile}.bak" ]; then
        cp "${asarFile}" "${asarFile}.bak" || exit 1
    fi

    # new format ... need to extract the asar file

    ## extract to temporary directory
    tmpDir=$(mktemp -d -t slackhackXXXXXXXXXXX)
    npx asar extract "$asarFile" "$tmpDir"
    echo "$tmpDir"

    ## patch the js file
    jsFile=$(find "$tmpDir" -name ssb-interop.bundle.js)
    patch_js_file "$jsFile" "$tmpDir"

    ## re-pack the archive and move it into place
    npx asar pack "$tmpDir" "${tmpDir}/app.asar"
    mv -f "${tmpDir}/app.asar" "$asarFile"

    ## clean-up the tmp dir ... note: currently this doesn't get cleaned up if we exit with an error
    rm -fr "tmpDir"

    echo "Please restart Slack if it is open."
fi




