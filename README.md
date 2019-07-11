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

## Developing

Dev mode will install the script but changes the url where the css files are loaded from to be `http://localhost:8164/` and then it starts up a mini http server to serve up the files in this repo. From there you can just start modifying the css files and hit `CMD+R` in slack to refresh.

You can run the installer in dev mode by running with the environment variable `DEV_MODE=true`. For example:

```bash
sudo DEV_MODE=true ./install.sh
```

You will also very likely want to run slack in dev mode as well, which gives you access to the developer tools to inspect elements, view network traffic, etc. This can be done by first closing your existing slack window and then running this in your terminal:

```bash
SLACK_DEVELOPER_MENU=true open -a /Applications/Slack.app
```

## Slack 4.0.0 update

In version 4.0.0 Slack moved the `ssb-interop` into the electron archive and it is now minified and obfuscated. Fortunately it appears patching the JS file can largely remain the same. The main difference now, is we need to:

1) Unpack the `app.asar` (the electron archive)
2) Patch the `ssb-interop.bundle.js` file ... just append same old snippet to the end of the file
3) Re-pack the `app.asar`
4) Restart Slack ... initial testing, I saw some wonkyness trying to just refresh after that change

I've made some updates to the installer to now check for this new file structure and added an attempt to patch the file. So far it looks good in the 2 minutes I've had it up.