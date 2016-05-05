require! \mix
require! \jade

mix = mix.init __dirname

mix.config.application-name ?= \Cornerstone

# index = jade.render (fs.read-file-sync "#__dirname/component/index.jade", 'utf8'), pretty: true
fs.write-file-sync "#__dirname/index.html", jade.render (fs.read-file-sync "#__dirname/component/index.jade", 'utf8'), pretty: true

try # Try old version of electron
  electron = require.cache[first((keys require.cache) |> filter -> /atom.asar\/browser\/api\/lib\/exports\/electron.js$/.test it)].exports
  menu     = require.cache[first((keys require.cache) |> filter -> /atom.asar\/browser\/api\/lib\/menu.js$/.test it)].exports
catch # New version
  electron = require.cache[first((keys require.cache) |> filter -> /browser\/api\/exports\/electron.js$/.test it)].exports
  menu     = require.cache[first((keys require.cache) |> filter -> /browser\/api\/menu.js$/.test it)].exports

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

electron.app.on \ready, ->
  menu.set-application-menu menu.build-from-template (require './menu').template electron.app
  size = electron.screen.get-primary-display!work-area-size
  electron.BrowserWindow.remove-dev-tools-extension "DevTools Theme: NightLion Dark"
  electron.BrowserWindow.add-dev-tools-extension "#__dirname/contrib/dev/theme"
  window = new electron.BrowserWindow do
    width: size.width - 100
    height: size.height - 200
  window.web-contents.open-dev-tools!
  window.loadURL "file://#__dirname/index.html"
  reload = debounce 100, window.web-contents.reload-ignoring-cache
  watcher.watch [ "#__dirname/component", "#__dirname/lib", "#__dirname/renderer.ls" ], persistent: true, ignore-initial: true .on 'all', (event, path) ->
    info "Change detected in '#path'..."
    reload!
