"use strict";


// ================================================================
// ================== Adaptive ====================================
// ================================================================

function add_screen_class () {
  var targets = $('html, body');
  var w       = (parseInt($(window).width() / 100) * 100);
  var actual_w= $(window).width();
  var c       = ((targets.attr('class') || '').split(' '));

  _.each(c, function (s) {
    if (s.match(/^w\d+(_plus|_minus)?$/))
      targets.removeClass(s);
  });

  targets.addClass('w' + w);

  _.each([400, 500, 600, 700, 800, 900, 1000, 1100, 1200], function (target) {
    if ( actual_w >= target)
      targets.addClass('w' + target + '_plus');
    if ( actual_w < target)
      targets.addClass('w' + target + '_minus');
  });

  log(targets.attr('class'));
}

$(function () {
  $(window).resize(function () {
    add_screen_class();
  });

  add_screen_class();

  $(window).load(function () {
    _.each([300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200], function (v) {
      $('html').addClass('max_' + screen.width );
      if (screen.width > v) {
        $('html').addClass('max_' + v + '_plus');
      }
    });
  });
});


