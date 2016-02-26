"use strict"
__appdir     = require('path').join(__dirname, '..')
__contentdir = "#{__appdir}/content"

calendarId   = '6gg9b82umvrktnjsfvegq1tb24'
gcal         = require('../lib/googlecalendar.coffee').GoogleCalendar(calendarId)

date         = require('../lib/date.coffee')
XRegExp      = require('xregexp').XRegExp
markdown     = require('marked')
fs           = require('fs')
yaml         = require('js-yaml')
S            = require('string')

# Content caching
cache      = undefined


getEvents = (callback) ->
  gcal.getJSON (err, data) ->
    events = []
    if data and data.description
      [talk1, talk2, talk3] = data.description.split('---')
    else
      [talk1, talk2, talk3] = ['', '', '']

    try
      markdown_talk1 = markdown(talk1)
    catch error
      console.log 'Error parsing talk 1 as Markdown: \n\t' + talk1
      markdown_talk1 = talk1

    try
      markdown_talk2 = markdown(talk2)
    catch error
      console.log 'Error parsing talk 2 as Markdown: \n\t' + talk2
      markdown_talk2 = talk2

    try
      markdown_talk3 = markdown(talk3)
    catch error
      console.log 'Error parsing talk 3 as Markdown: \n\t' + talk3
      markdown_talk3 = talk3

    if data
      events.push
        date: new Date(data.start.dateTime)
        talk1: markdown_talk1
        talk2: markdown_talk2
        talk3: markdown_talk3

    callback null, events

getContentSnippets = (view, callback) ->
  results = []
  dir = "#{__contentdir}/#{view}"
  fs.readdir dir, (err, list) ->
    if (err) then return callback(err)
    pending = list.length
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


getSlots = (callback) ->
  getContent 'talks', (err, data) ->
    selectedYear = String( (new Date()).getFullYear() )
    if (err) then callback(err)
    content = {}

    if data
      if data[selectedYear]
        content = data[selectedYear][0]
      else
        content = data[selectedYear - 1][0]

    callback(null, content)

exports.init = (app) ->
  cache = require('../lib/pico.coffee').Pico(app.settings.cacheInSeconds)



# Routes
exports.index = (req, res) ->
  content = undefined
  if content
    res.render 'index', content
  else
    getSlots (err, data) ->
      if data
        res.locals.slots = data
      else
        console.log err

    getEvents (err, data) ->
      if data
        content = { 'events': data }
        # Store content in cache
        cache.set 'websiteContent', content

      else
        console.log err

      res.render 'index', content

exports.about = (req, res) ->
  res.render 'about', {
    'selectedView': 'about'
  }

exports.talks = (req, res) ->
  getContent 'talks', (err, data) ->
    selectedYear = String( req.params[0] || (new Date()).getFullYear() )

    if not data.hasOwnProperty(selectedYear)
      selectedYear = selectedYear - 1

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
      'selectedView': 'talks'
      'content'     : data
    }


exports.robots = (req, res) ->
  res.send("User-agent: *\nDisallow: /");

exports.e404 = (req, res) ->
  res.status 404
  res.render '404'
