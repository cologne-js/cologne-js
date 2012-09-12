"use strict"
__appdir     = require('path').join(__dirname, '..')
__contentdir = "#{__appdir}/content"

calendarId   = 'podoldti665gcdmmt7u72v62fc'
gcal         = require('../lib/googlecalendar.coffee').GoogleCalendar(calendarId)

date         = require('../lib/date.coffee')
XRegExp      = require('xregexp').XRegExp;
markdown     = require('node-markdown').Markdown
fs           = require('fs')
yaml         = require('js-yaml')


# Content caching
cache      = undefined


getEvents = (callback) ->
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

      callback null, events
    else
      callback new Error('Could not load events from Google Calendar')


getContentSnippets = (view, callback) ->
  results = []
  dir = "#{__contentdir}/#{view}"
  fs.readdir dir, (err, list) ->
    if (err) then return callback(err)
    pending = list.length;
    if (!pending) then return callback null, results.sort()
    list.forEach (file) ->
      fileFullName = "#{dir}/#{file}"
      fs.stat fileFullName, (err, stat) ->
        if stat and stat.isFile() then results.push(file)
        if (!--pending) then callback(null, results.sort())


getContent = (view, callback) ->
  getContentSnippets view, (err, result) ->
    if (err) then callback(err)
    content = {}
    result.forEach (file) ->
      try
        content[ file.replace(/\.yml/, '') ] = yaml.load fs.readFileSync("#{__contentdir}/#{view}/#{file}", 'utf-8')
      catch error
    callback(null, content)


exports.init = (app) =>
  cache = require('../lib/pico.coffee').Pico(app.settings.cacheInSeconds)


# Routes
exports.index = (req, res) ->
  content = cache.get 'websiteContent'
  if content
    res.render 'index', content
  else
    getEvents (err, data) ->
      if data
        content = { 'events': data }

        # Store content in cache
        cache.set 'websiteContent', content

      else
        console.log err

      res.render 'index', content


exports.talks = (req, res) ->
  getContent 'talks', (err, data) ->
    selectedYear = String( req.params[0] || (new Date()).getFullYear() )
    if err then console.log err
    if err or not data.hasOwnProperty(selectedYear)
      exports.e404(req, res)
      return

    for own year, months of data
      for month in months
        for talk in month.talks
          talk.description = markdown(talk.description) if talk.description

    res.render 'talks', {
      'title'       : "Talks #{selectedYear}"
      'years'       : (String(year) for own year of data).reverse()
      'selectedYear': selectedYear
      'content'     : data
    }


exports.ical = (req, res) ->
  res.redirect gcal.getICalUrl()


exports.e404 = (req, res) ->
  res.status 404
  res.render '404'