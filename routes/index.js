var strfdate = require('../lib/strfdate');

module.exports = function(req, res) {
  var nextEvent = req.app.get('events').getNextEvent();

  res.render(
    'index',
    {
      nextDate: (nextEvent && nextEvent.date) ? strfdate('%B, %o %Y', new Date(nextEvent.date)) : 'tba.',
      talks: (nextEvent && nextEvent.talks) ? nextEvent.talks : undefined
    }
  );
};
