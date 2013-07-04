"use strict"

express = require('express')
routes  = require('./routes')
app     = module.exports = express()

logErrors = (err, req, res, next) ->
  console.error err.stack
  next err

errorHandler = (err, req, res, next) ->
  res.status 500
  res.render 'error', { error: err }


# Configuration
app.configure () ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static(__dirname + '/public')
  app.use app.router

app.configure 'development', () ->
  edt = require('express-debug')
  edt app, {}
  app.set 'cacheInSeconds', 0
  app.set 'port', 3333
  app.use logErrors
  app.use errorHandler

app.configure 'production', () ->
  app.set 'cacheInSeconds', 60 * 60
  app.set 'port', process.env.PORT or 5000
  app.use errorHandler

# Routes
routes.init app
app.get  '/',                       routes.index
app.get  '/about',                  routes.about
app.get  /^\/talks\/?(\d{4})?\/?$/, routes.talks
app.get  '/praguejs.ics',           routes.ical
app.get  '/robots.txt',             routes.robots
app.get  '/*',                      routes.e404

server = app.listen app.settings.port
console.log "Express server listening in #{ app.settings.env } mode at http://localhost:#{ server.address().port }/"