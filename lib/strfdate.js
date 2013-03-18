var strftime = require('strftime');


// Returns an ordinal number. 13 -> 13th, 21 -> 21st etc.
var ordinal = function(number) {
  number = Number(number) || 0;

  if ( (number % 100) > 10 && (number % 100) < 14 ) {
    return number + 'th';
  } else {
    switch (number % 10) {
      case 1:
        return number + 'st';
      case 2:
        return number + 'nd';
      case 3:
        return number + 'rd';
      default:
        return number + 'th';
    }
  }
};


module.exports = function(format, date) {

  if (date.constructor.toString().indexOf('Date()') === -1) {
    date = new Date(date);
  }

  // Add ordinal day output
  if (/%o/.test(format)) {
    var day = ordinal( date.getDate() );
    format = format.replace(/%o/, day);
  }
  return strftime(format, date);

};
