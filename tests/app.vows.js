require.paths.unshift("../node_modules/");
require.paths.unshift(".");

var vows = require('vows'),
		assert = require('assert'),
		http = require('http');

require('../app');

var client = http.createClient(3333, 'localhost');

//helper
function assertStatus(code) {
	return function (res, y) {
		assert.equal (res.statusCode, code);
	};
}
var api = {
	get: function (path) {
		return function () {
			var request = client.request('GET', path, {'host': 'localhost:8000'});
			request.end();
			request.on('response', this.callback);
		};
	}
};

vows.describe('app').addBatch({
	'app serves root': {
		topic: api.get('/'),
		'should respond with a 200': assertStatus(200)
	}
}).export(module);