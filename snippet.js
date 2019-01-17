// START MASHUPMILL/SLACK-THEMES -- DO NOT MODIFY
const enableDarkMode = true;

if (enableDarkMode) {
  const fetchCss = url => fetch(url).then(response => response.text());
  // Slack Night Mood theme
  document.addEventListener("DOMContentLoaded", function() {
      // Then get its webviews
      let webviews = document.querySelectorAll(".TeamView webview");

      const cssUrls = ['https://raw.githubusercontent.com/MashupMill/slack-themes/master/black.css', 'https://raw.githubusercontent.com/MashupMill/slack-themes/master/theme-black.css'];

      const cssPromise = Promise.all(cssUrls.map(url => fetchCss(url))).then(cssFiles => cssFiles.join("\n"));

      // Insert a style tag into the wrapper view
      cssPromise.then(css => {
        let s = document.createElement('style');
        s.type = 'text/css';
        s.innerHTML = css;
        document.head.appendChild(s);
      });
      // Wait for each webview to load
      webviews.forEach(webview => {
          webview.addEventListener('ipc-message', message => {
              if (message.channel == 'didFinishLoading')
              // Finally add the CSS into the webview
                  cssPromise.then(css => {
                  let script = `
  let s = document.createElement('style');
  s.type = 'text/css';
  s.id = 'slack-custom-css';
  s.innerHTML = \`${css}\`;
  document.head.appendChild(s);
  `
                  webview.executeJavaScript(script);
              })
          });
      });
  });
}
// END MASHUPMILL/SLACK-THEMES -- DO NOT MODIFY
