"use strict"

express = require('express')
routes  = require('./routes')

app     = module.exports = express.createServer()

# Configuration
app.configure () ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static(__dirname + '/public')
  app.use app.router

app.configure 'development', () ->
  app.set 'cacheInSeconds', 0
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', () ->
  app.set 'cacheInSeconds', 60 * 60
  app.use express.errorHandler()


# Routes
routes.init app
app.get  '/',                       routes.index
app.get  '/about',                  routes.about
app.get  /^\/talks\/?(\d{4})?\/?$/, routes.talks
app.get '/colognejs.ics',           routes.ical
app.get  '/*',                      routes.e404


app.listen 3333
console.log "Express server listening in #{ app.settings.env } mode at http://localhost:#{ app.address().port }/"