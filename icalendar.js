var icalendar = {};


icalendar.value = function (line) {
    line = line.split(':')[1];
    return line.replace(/\r/, '');
};

icalendar.date = function (line) {
    line = line.split(':')[1];
    var year = line.substr(0, 4);
    var month = line.substr(4, 2);
    var day = line.substr(6, 2);
    var hour = parseInt(line.substr(9, 2)) + 2; //GMT => CET
    var minutes = line.substr(11, 2);
    return new Date(year, month-1, day, hour, minutes);
};
icalendar.parse = function (data) {
    var lines = data.split('\n');
    var events = [];
    var currentevent;
    lines.forEach(function(line) {
        if(line.match('^BEGIN:VEVENT')) currentevent = {};
        if(line.match('^DTSTART')) currentevent.start = icalendar.date(line);
        if(line.match('^DTEND')) currentevent.end = icalendar.date(line);
        if(line.match('^SUMMARY')) currentevent.summary = icalendar.value(line);
        if(line.match('^END:VEVENT')) {
            currentevent.datestr = currentevent.start.toLocaleString().substr(0, 15);
            events.push(currentevent);
            currentevent = null;
        }
    });
    events.sort(function(a, b) { return a.start.getTime() > b.start.getTime(); });
    return events;
};
module.exports = icalendar;
