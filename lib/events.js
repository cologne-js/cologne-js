var fs   = require('fs'),
    path = require('path'),
    yaml = require('js-yaml');


if (!Array.prototype.unique) {
  Array.prototype.unique = function(){
    var u = {}, a = [];
    for(var i = 0, l = this.length; i < l; ++i) {
      if(u.hasOwnProperty(this[i])) { continue; }
      a.push(this[i]);
      u[this[i]] = 1;
    }
    return a;
  };
}


module.exports = (function() {
  var sortDescendingByYear = function(a, b) {
    if (a.date > b.date) {
      return -1;
    } else if (a.date < b.date) {
      return 1;
    }
    return 0;
  };


  var loadEvents = function() {
    var content = [];
    fs.readdirSync(basepath).forEach(function(item) {
      var basename = item.substr(0, item.lastIndexOf('.'));
      content.push({
        date  : basename,
        talks : yaml.load( fs.readFileSync(basepath + item, 'utf-8') )
      });
    });
    return content;
  };


  var basepath = path.join(__dirname, '../events/');
  var events   = loadEvents().sort(sortDescendingByYear);


  return {
    getEvents: function() {
      return events;
    },

    getPastEvents: function(limit) {
      var today = (new Date()).toISOString().substr(0, 10);

      limit |= events.length;
      return events.filter(function(item) {
        return (item.date <= today);
      }).slice(0, limit);
    },

    getPastEventsForYear: function(year) {
      return this.getPastEvents().filter(function(item) {
        return (item.date.indexOf(year) === 0);
      });
    },

    getNextEvent: function() {
      var today = (new Date()).toISOString().substr(0, 10);
      var nextEvent;
      for (var i=0, len=events.length; i<len; i++) {
        if (events[i].date >= today) {
          nextEvent = events[i];
        }
      }
      return nextEvent;
    },

    getYears: function() {
      return events.map(function(item) {
        return Number(item.date.substr(0, 4));
      }).unique();
    }
  };
})();
