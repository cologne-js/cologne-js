var express = require('express'),
    http    = require('http');


// Load routes
var routes = {};
['index', 'about', 'talks', 'atom', 'ical', 'error404'].forEach(function(element) {
  routes[element] = require('./routes/' + element);
});


var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('env', process.env.NODE_ENV || 'development');
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');

  // Load all event data into memory
  app.set('events', require('./lib/events'));

  app.use(express.favicon(__dirname + '/public/favicon.ico', { maxAge: 2592000000 }));
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());

  app.use(require('stylus').middleware({
    src: __dirname + '/public',
    compress: (app.get('env') === 'production')
  }));

  app.use(express.static(__dirname + '/public'));
  app.use(app.router);
});

app.configure('development', function() {
  app.set('baseurl', 'http://localhost:' + app.get('port'));
  app.use(express.errorHandler());
});

app.configure('production', function() {
  app.set('baseurl', 'http://colognejs.de');
});

app.get('/',                       routes.index);
app.get('/about',                  routes.about);
app.get(/^\/talks\/?(\d{4})?\/?$/, routes.talks);
app.get('/atom.xml',               routes.atom);
app.get('/colognejs.ics',          routes.ical);
app.get('/*',                      routes.error404);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server in \x1B[1m\x1B[31m' + app.get('env') + '\x1B[39m: http://localhost:\x1B[1m\x1B[31m' + app.get('port') + '\x1B[39m');
});