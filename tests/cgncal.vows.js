require.paths.unshift("../vendor/lib");
require.paths.unshift(".");

var vows = require('vows'),
    assert = require('assert'),
    util = require('util'),
    cgncal = require('cgncal');

vows.describe('calendar').addBatch({
	'module': {
		topic: cgncal,
		'should be available': function(topic){
			assert.isNotNull(topic);
		},
		'should provide a get dates function': function(topic){
			assert.isFunction(topic.fetchDates);
		} 
	},
	'fetchDates': {
		topic: function () {
		    var cal = Object.create(cgncal);
		    cal.fetchDates(this.callback)
		},
		'should parse the XML': function(result){
            assert.equal(result[0].summary, 'CologneJS 2011.02');
		} 
	},
		
}).export(module, {error:false});