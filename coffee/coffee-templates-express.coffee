# CoffeeTemplates.__express
# provided as an example only
# as you can see, there are a lot of possible ways it can be used
# so customization is required
require_fresh=(a)->delete require.cache[require.resolve a];require a
app.locals require_fresh app.SHARED_HELPERS+'templates'
app.response._render = app.response.render
app.response.render = (name, options, cb) ->
  options = options or {}
  options.view = name
  options.layout =
    if options.layout
      path.join 'shared', 'layouts', options.layout
    else
      path.join 'shared', 'layouts', 'application'
  if name.indexOf('server'+path.sep) is 0
    name = path.join 'app', 'views', 'templates'
  else # shared
    name = path.join 'public', 'assets', 'templates'
  @_render name, options, cb
app.set 'view engine', 'js'
app.set 'views', app.STATIC
app.engine 'js', (file, options, cb) ->
  fs.readFile file, 'utf8', (err, templates) ->
    if file.indexOf(path.join 'static', 'app', 'views', 'templates.js') isnt -1 # server-only template requested
      # splice-in shared templates; this extra cpu avoids double-tree stored on disk
      fs.readFile app.ASSETS+'templates.js', 'utf8', (err, shared_templates) ->
        templates = templates.split("\n")
        templates.splice -2, 0, shared_templates.split("\n").slice(2,-2).join("\n")
        render templates.join("\n")
    else
      render templates
  render = (js) ->
    eval js # returns templates() function
    #console.log "rendering with options", options
    cb null, templates options.view, options
