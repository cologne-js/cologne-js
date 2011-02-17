var http = require('http')
  , icalendar = require('icalendar')
  , util = require('sys') //Node v.0.2.2 compatibility

var cgncal = function() {}
cgncal.create = function(url) {
  var self = new this()
  self.url = url
  self.client = http.createClient(80, 'www.google.com')
  return self
}
cgncal.prototype.fetchDates = function (callback) {
  var self = this
    , request = self.client.request('GET', self.url, {'host': 'www.google.com'})
    , done = false

  var cb = function(err, dates) {
    if (done === false) {
      done = true
      callback(err, dates)
    }
  }

  setTimeout(function() {
    // timeout cancel request
    //request.abort()
    cb(new Error('Could not fetch dates from calendar'))
  }, 1000)

  request.end();

  var data = ""
  request.on('response', function (response) {
    response.setEncoding('utf8');
    response.on('data', function (chunk) { data += chunk });
    response.on('end', function () {
      cb(null, icalendar.parse(data));
    })
  })
}

module.exports = cgncal;

