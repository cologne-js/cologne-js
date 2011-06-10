require.paths.unshift("../node_modules/");
require.paths.unshift(".");

var vows = require('vows'),
    assert = require('assert'),
    util = require('util'),
    cgncal = require('cgncal');

vows.describe('calendar').addBatch({
	
	'module': {
		topic: function() {
			return cgncal
		},
		'should be available': function(topic){
			assert.isNotNull(topic);
		},
		'should provide a get dates function': function(topic){
			assert.isFunction(topic.prototype.fetchDates);
		} 
	},
	'fetchDates': {
		topic: function () {
			var cal = cgncal.create('/calendar/ical/podoldti665gcdmmt7u72v62fc%40group.calendar.google.com/public/basic.ics')
			cal.fetchDates(this.callback)
		},
		'should parse the XML': function(err, result){
			assert.equal(result[0].summary, 'CologneJS 2011.06');
		} 
	},
		
}).export(module);