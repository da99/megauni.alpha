"use strict";

var ALL_WHITE_SPACE  = /\s+/g;


// =======================================================================================

var do_nothing = function() {};

function func() {
  return _.partial.apply(_, arguments);
}

function show_option(e) {
  var parent = $(this).parents('div.box');
  parent.find('div.content').show();
  $(this).hide();
  $(parent.find('a.off')[0]).show();
}

function hide_option(e) {
  var parent = $(this).parents('div.box');
  parent.find('div.content').hide();
  $(this).hide();
  $(parent.find('a.on')[0]).show();
}

$(function () {
  $('#Options a.on').each(function (i, l) {
    on_click(l, show_option);
  });

  $('#Options a.off').each(function (i, l) {
    on_click(l, hide_option);
  });
});
