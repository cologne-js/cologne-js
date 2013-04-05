var strfdate = require('../lib/strfdate');

module.exports = function(req, res) {
  var events = req.app.get('events').getEvents();

  events.forEach(function(item) {
    item.formattedDate = strfdate('%Y.%m',  item.date);
    item.icalDate      = strfdate('%Y%m%d', item.date);
  });

  res.set('Content-Type', 'text/calendar; charset=utf-8');
  res.render(
    'ical',
    {
      baseurl      : req.app.get('baseurl'),
      events       : events
    }
  );
};

