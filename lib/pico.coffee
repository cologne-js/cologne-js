# pico: plain in-memory cache object

class exports.Pico
  constructor: (@cachingTime = 60) ->
    if not (this instanceof Pico) then return new Pico(@cachingTime)
    @cache = []

  set: (key, value) ->
    @cache[key] = value
    setTimeout (=> @cache[key] = null), @cachingTime * 1000

  get: (key) ->
    if @cache then return @cache[key]
