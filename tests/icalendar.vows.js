require.paths.unshift("../vendor/lib");
require.paths.unshift(".");

var vows = require('vows'),
assert = require('assert'),
util = require('util'),
fs = require('fs'),
icalendar = require('icalendar');

vows.describe('icalendar').addBatch({
    'module': {
        topic: icalendar,
        'should be available': function(topic){
            assert.isNotNull(topic);
        },
        'should provide a parse function': function(topic){
            assert.isFunction(topic.parse);
        } 
    },
    'basic parsing': {
        topic: function() {
            var file = fs.readFileSync(__dirname + '/basic.ics', 'utf8');            
            return icalendar.parse(file);
        },
        'should' : function(result) {
            assert.equal(result[0].summary, 'CologneJS 2011.02');
            assert.equal(result[0].start.getDate(), '8');
            assert.equal(result[0].start.getMonth(), '1');
            assert.equal(result[0].datestr, 'Tue Feb 08 2011');
            assert.equal(result[1].summary, 'CologneJS 2011.03');
            assert.equal(result[1].start.getDate(), '15');
            assert.equal(result[1].start.getMonth(), '2');
            assert.equal(result[2].summary, 'CologneJS 2011.04');
            assert.equal(result[2].start.getDate(), '12');
            assert.equal(result[2].start.getMonth(), '3');            
        }
    }
}).export(module, {error:false});