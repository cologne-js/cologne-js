calendarId = 'podoldti665gcdmmt7u72v62fc'
gcal       = require('../lib/googlecalendar.coffee').GoogleCalendar(calendarId)

XRegExp    = require('xregexp').XRegExp;
date       = require('../lib/date.coffee')
markdown   = require('node-markdown').Markdown

# Content caching
cache      = undefined


exports.init = (app) =>
  cache = require('../lib/pico.coffee').Pico(app.settings.cacheInSeconds)


# Routes
exports.index = (req, res) ->
  content = cache.get 'websiteContent'
  if content
    res.render 'index', content
  else
    gcalOptions =
      'futureevents': true
      'orderby'     : 'starttime'
      'sortorder'   : 'ascending'
      'fields'      : 'items(details)'
      'max-results' : 3

    gcal.getJSON gcalOptions, (err, data) ->
      if data && data.length
        events = []
        for item in data
          regex = XRegExp('Wann:.*?(?<day>\\d{1,2})\\. (?<month>\\w+)\\.? (?<year>\\d{4})')
          parts = XRegExp.exec(item.details, regex)
          foo = date.convert(parts.year, parts.month, parts.day)

          talks = XRegExp.exec(item.details, XRegExp('Terminbeschreibung: (.*)', 's'))
          if (talks && talks[1])
            [talk1, talk2] = talks[1].split('---')
          else
            [talk1, talk2] = ['', '']

          events.push
            date: date.format(foo, "%b %%o, %Y")
            talk1: markdown(talk1)
            talk2: markdown(talk2)

        content =
          'events': events

        # Store content in cache
        cache.set 'websiteContent', content

      else
        content =
          'events': []
        console.log err

      res.render 'index', content


exports.ical = (req, res) ->
  res.redirect gcal.getICalUrl
