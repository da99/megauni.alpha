// ================================================================
// ================== Time ========================================
// ================================================================

// Modified From: http://stackoverflow.com/questions/6637574/how-to-format-now-with-jquery
function time_for_humans(t) {
  var now = (new Date).getTime();
  var diff = (now - t);

  if (diff < 5000) {
    return "a few seconds ago";
  }

  var vals = [
    [(diff / 1000 / 60 / 60 / 24), 'day'],
    [(diff / 1000 / 60 / 60)     , 'hr'],
    [(diff / 1000 / 60)          , 'min'],
    [(diff / 1000)               , 'sec'],
  ];

  var highest = _.detect(vals, function (pair) {
    return parseInt(pair[0]) > 0;
  }) || [0, 'sec'];

  highest[0] = parseInt(highest[0]);
  highest.push('ago');

  if (highest[0] > 1)
    highest[1] = highest[1] + 's';

  if (highest[0] < 1)
    highest[0] = "<1";

  return highest.join(' ');

}

function in_secs(num, func) {
  setTimeout(func, num * 1000);
}

function every_secs(num, func) {
  setInterval(func, num * 1000);
}


function min_sec(v) {
  var min = parseInt(v/1000/60);
  var sec = parseInt( (v - (min * 1000 * 60)) / 1000 );
  return min + ':' + ((sec < 10) ? '0' + sec : sec);
}

function every_sec(se, func) {
  var start = (new Date).getTime();
  var update = function () {
    var target = $(se);
    if (!target.length)
      return;
    if( func(target, (new Date).getTime() - start ) )
      setTimeout(update, 1000);
  };

  update();
};
