request  = require 'request'
strftime = require('strftime').strftime

dateFormat = "%d-%m-%Y"

# Date formatting routines
# Returns an ordinal number. 13 -> 13th, 21 -> 21st etc.
ordinal = (number) ->
  number = parseInt(number, 10)
  if 10 > (number % 100) > 14
    "#{number}th"
  else
    switch number % 10
      when 1 then "#{number}st"
      when 2 then "#{number}nd"
      when 3 then "#{number}rd"
      else        "#{number}th"


exports.setDateFormat = (format) ->
  dateFormat = format


formatDate = (date) ->
  formattedDate = strftime(dateFormat, date)

  # Add ordinal day output
  if /%o/.test(dateFormat)
    day = ordinal(date.getDate())
    formattedDate.replace(/%o/, day)


# iCalendar parsing
parseValue = (line) ->
  line = line.split(':')[1]
  return line.replace(/\r/, '')


parseDate = (line) ->
  line    = line.split(':')[1]
  year    = line.substr(0, 4)
  month   = line.substr(4, 2)
  day     = line.substr(6, 2)
  hour    = parseInt(line.substr(9, 2), 10) + 2 # GMT => CET
  minutes = line.substr(11, 2)
  return new Date(year, month-1, day, hour, minutes)


exports.parse = (data, removePastEvents) ->
  lines = data.split '\n'
  events = []

  for line in lines
    if /^BEGIN:VEVENT/.test(line) then currentevent = {}
    if currentevent
      if /^DTSTART/.test(line)
        currentevent.start = parseDate(line)
        currentevent.startFormatted = formatDate(currentevent.start)
      if /^DTEND/.test(line)
        currentevent.end = parseDate(line)
        currentevent.endFormatted = formatDate(currentevent.end)
      if /^SUMMARY/.test(line)
        currentevent.summary = parseValue(line)
      if /^DESCRIPTION/.test(line)
        currentevent.description = parseValue(line)
      if currentevent.description
        # Descriptions in Google Calendar files can spread over multiple lines.
        # New lines start with a space.
        currentevent.description += line.replace(/(^ |\r)/, '') unless /^[A-Z]{3,}/.test(line)
      if /^END:VEVENT/.test(line)
        currentevent.description = currentevent.description.replace(/\\n/g, '<br>')
        events.push(currentevent)
        currentevent = null

  events.sort (a, b) ->
    return a.start.getTime() > b.start.getTime()

  if removePastEvents then events = events.filter (element, index, array) ->
    return element.end.getTime() > Date.now()

  return events


exports.fromUrl = (url, callback) ->
  request { uri: url, timeout: 1000 }, (err, res, body) =>
    if (res && res.statusCode isnt 200) then err = res.statusCode
    if err
      callback new Error 'Could not fetch dates from calendar'
      return
    else
      callback null, @parse(body, true)
      return
