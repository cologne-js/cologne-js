"use strict"

express = require('express')
bodyParser = require('body-parser')
methodOverride = require('method-override')
routes  = require('./routes')
app     = module.exports = express()

logErrors = (err, req, res, next) ->
  console.error err.stack
  next err

errorHandler = (err, req, res, next) ->
  res.status 500
  res.render 'error', { error: err }


# Configuration
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: true })
app.use methodOverride()
app.use express.static(__dirname + '/public')

if process.env.NODE_ENV is 'production'
  app.set 'cacheInSeconds', 60 * 60
  app.set 'port', process.env.PORT or 5000
  app.use errorHandler
else
  edt = require('express-debug')
  edt app, { depth: 6}
  app.set 'cacheInSeconds', 0
  app.set 'port', 3000
  app.use logErrors
  app.use errorHandler

# Routes
routes.init app
app.get  '/',                       routes.index
app.get  '/about',                  routes.about
app.get  /^\/talks\/?(\d{4})?\/?$/, routes.talks
app.get  '/robots.txt',             routes.robots
app.get  '/*',                      routes.e404

server = app.listen app.settings.port
console.log "Express server listening in #{ app.settings.env } mode at http://localhost:#{ server.address().port }/"
