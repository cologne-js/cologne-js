# pico: plain in-memory cache object

class exports.Pico
  constructor: (@cachingTime = 60 * 1000) ->
    if not (this instanceof Pico) then return new Pico
    @cache = []
  
  set: (key, value) ->
    @cache[key] = value
    setTimeout (=> @cache[key] = null), @cachingTime
  
  get: (key) ->
    if @cache then return @cache[key]
