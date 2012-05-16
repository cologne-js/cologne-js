express  = require 'express'
markdown = require('node-markdown').Markdown
ical     = require('./lib/icalendar.coffee')

calendar = 'https://www.google.com/calendar/ical/podoldti665gcdmmt7u72v62fc%40group.calendar.google.com/public/basic.ics'

app = module.exports = express.createServer()

# Configuration
app.configure () ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

app.configure 'development', () ->
  app.set 'cacheInSeconds', 0
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', () ->
  app.set 'cacheInSeconds', 60 * 60
  app.use express.errorHandler()


# Content caching
cache = require('./lib/pico.coffee').Pico(app.settings.cacheInSeconds)


# Routes
app.get '/', (req, res) ->
  content = cache.get 'websiteContent'
  if content
    res.render 'index', content
  else
    # %o is custom date format, needs double escapement
    ical.setDateFormat "%b %%o, %Y"
    ical.fromUrl calendar, (err, events) ->
      if events && events.length
        [ nextEvent, futureEvents ] = [ events[0], events[1..-1] ]

        content =
          nextMeetup:
            date: nextEvent.startFormatted
            talks: markdown(nextEvent.description) || 'tbd.'
          futureMeetups: futureEvents.slice(0, 2)
          nodeversion: process.version

        # Store content in cache
        cache.set 'websiteContent', content

      else
        content =
          nextMeetup:
            date: '(couldn\'t retrieve calendar data)'
            talks: '(couldn\'t retrieve calendar data)'
          futureMeetups: []
          nodeversion: process.version

      res.render 'index', content

app.get '/colognejs.ics', (req, res) ->
  res.redirect calendar, 301


app.listen 3333
console.log "Express server listening in #{app.settings.env} mode at http://localhost:#{app.address().port}/"