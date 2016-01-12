strftime = require('strftime')
months   = ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez']

# Date formatting routines
# Returns an ordinal number. 13 -> 13th, 21 -> 21st etc.
ordinal = (number) ->
  number = parseInt(number, 10)
  if 10 < (number % 100) < 14
    "#{number}<sup>th</sup>"
  else
    switch number % 10
      when 1 then "#{number}<sup>st</sup>"
      when 2 then "#{number}<sup>nd</sup>"
      when 3 then "#{number}<sup>rd</sup>"
      else        "#{number}<sup>th</sup>"


exports.convert = (year, month, day) ->
  position = months.indexOf(month)
  if (position isnt -1) then month = position
  new Date(year, month, day)


exports.format = (date, format = "%d-%m-%Y") ->
  formattedDate = strftime(format, date)

  # Add ordinal day output
  if /%o/.test(formattedDate)
    day = ordinal(date.getDate())
    formattedDate = formattedDate.replace(/%o/, day)

  return formattedDate
