request  = require 'request'

class exports.GoogleCalendar
  constructor: (@calendarId) ->
    if not (this instanceof GoogleCalendar) then return new GoogleCalendar(@calendarId)

  getUrl: (controller = 'ical')->
    "https://www.google.com/calendar/#{ controller }/#{ @calendarId }%40group.calendar.google.com/public/basic"

  getICalUrl: ->
    "#{ @getUrl() }.ics"

  getJSON: (parameters, callback) ->
    url = "#{ @getUrl('feeds') }?#{ serializeObject(parameters) }&alt=jsonc"

    request { uri: url, timeout: 2000 }, (err, res, body) =>
      if (res && res.statusCode isnt 200) then err = res.statusCode
      if err
        callback new Error 'Could not fetch dates from calendar: ' + err
        return
      else
        try
          items = JSON.parse(body).data.items
          callback null, items
        catch err
          callback new Error 'Could not fetch dates from calendar: ' + err
        return


serializeObject = (obj) ->
  pairs = []
  for own key, value of obj
    pairs.push "#{encodeURIComponent( key )}=#{encodeURIComponent( value )}"
  pairs.join '&'