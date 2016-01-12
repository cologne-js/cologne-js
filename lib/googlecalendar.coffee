google = require 'googleapis'
fs = require 'fs'

class exports.GoogleCalendar
  constructor: (@calendarId) ->
    if not (this instanceof GoogleCalendar) then return new GoogleCalendar(@calendarId)

  getApiKey = ->
    if fs.existsSync 'api_key.json'
      data = fs.readFileSync __dirname + '/../api_key.json'
      obj = JSON.parse data
      return obj.api_key
    else
      throw 'Missing api_key.json'


  getJSON: (callback) ->
    calendar = google.calendar 'v3'
    API_KEY = getApiKey()
    calendar.events.list {
      key: API_KEY
      calendarId: "#{@calendarId}@group.calendar.google.com"
      timeMin: (new Date).toISOString()
      maxResults: 1
      singleEvents: true
      orderBy: 'startTime'
    }, (err, response) ->
      if err
        console.log 'The API returned an error: ' + err
        return callback err
      events = response.items
      if events.length == 0
        callback null, null
      else
        event = events[0]
        callback null, event
