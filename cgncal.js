var url = '/calendar/ical/podoldti665gcdmmt7u72v62fc%40group.calendar.google.com/public/basic.ics';

//url = '?output=rss'
var http = require('http'),
    icalendar = require('icalendar'),
    util = require('util');

var cgncal = {};

cgncal.fetchDates = function (callback) {
    var self = this;
    var google = http.createClient(80, 'www.google.com');
    var request = google.request('GET', url, {'host': 'www.google.com'});
    request.end();
    var data = "";
    request.on('response', function (response) {
        response.setEncoding('utf8');
        response.on('data', function (chunk) {
            data += chunk;
        });
        response.on('end', function () {
            callback(icalendar.parse(data));
        });
    });   
};


module.exports = cgncal;


