# slack-themes

## Installation

Run the following command...

```bash
curl -s https://raw.githubusercontent.com/MashupMill/slack-themes/master/install.sh | sudo bash
```

> Note: Currently this script is written for macOS (basically its just the path to slack that is specific to macOS). Though it may work on other systems if you take the [`install.sh`](./install.sh) script and run it like `sudo ./install.sh /path/to/Slack`

## Manual Installation

Add the contents of [`snippet.js`](./snippet.js) to your `ssb-interop.js` (typically found at `/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static/ssb-interop.js`)

## Uninstallation
Remove the entire snippet of code in `ssb-interop.js` between (inclusively) `// START MASHUPMILL/SLACK-THEMES -- DO NOT MODIFY` and `// END MASHUPMILL/SLACK-THEMES -- DO NOT MODIFY`
