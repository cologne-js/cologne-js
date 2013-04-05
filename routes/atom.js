var strfdate = require('../lib/strfdate');

module.exports = function(req, res) {
  var events = req.app.get('events').getPastEvents(12);

  events.forEach(function(item) {
    item.formattedDate = strfdate('%B %Y', item.date);
    item.year          = (new Date(item.date)).getFullYear();
    item.isoDate       = (new Date(item.date)).toISOString();
  });

  res.set('Content-Type', 'application/atom+xml; charset=utf-8');
  res.render(
    'atom',
    {
      baseurl      : req.app.get('baseurl'),
      updated      : events[0] ? (new Date(events[0].date)).toISOString() : (new Date()).toISOString(),
      events       : events
    }
  );
};




