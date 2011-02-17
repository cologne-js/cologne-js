/**
 * Module dependencies.
 */
var express = require('express')
  , connect = require('connect')
  , cgncal = require('cgncal').create('/calendar/ical/podoldti665gcdmmt7u72v62fc%40group.calendar.google.com/public/basic.ics')
  , upcoming_dates = []

// Create and export Express app

var app = express.createServer();

// Configuration

app.configure(function(){
    app.set('views', __dirname + '/views');
    app.use(connect.bodyDecoder());
    app.use(connect.methodOverride());
    app.use(connect.compiler({ src: __dirname + '/public', enable: ['sass'] }));
    app.use(connect.staticProvider(__dirname + '/public'));
});

app.configure('development', function(){
    app.set('reload views', 1000);
    app.use(connect.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
   app.use(connect.errorHandler());
});

// Routes

// update dates every hour
setInterval(function() {
  cgncal.fetchDates(function(err, dates) {
    if (err) upcoming_dates = []
    else upcoming_dates = dates
  })
}, 3600000)

app.get('/', function(req, res){
  res.render('index.jade', {
    locals: {
      title: 'Cologne.js',
      dates: upcoming_dates,
      nodeversion: process.version
    }
  })
})

app.listen(parseInt(process.env.PORT || 3333), null);
console.log("now running on http://localhost:" + (process.env.PORT || 3333));

process.on('uncaughtException', function (err) {
    console.log('Caught exception: ' + err);
});

