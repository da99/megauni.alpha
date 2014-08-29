"use strict";

function do_nothing (){
  log('Doing nothing', arguments);
}

function log_length(se, orig) {
  var e = $(se);
  if (!e.length)
    log('None found for: ', (e.selector || se.selector || se));
  return e;
}

function show(se) {
  return log_length(se).show();
}

function hide(se) {
  return log_length(se).hide();
}

function outer_html(se) {
  return log_length(se).wrap('<p/>').parent().html();
}


// ============================================
// Note:
// Selector for new_se must be in the form of:
//   TAG.class
// ============================================
function after(se, new_se, txt) {

  var e      = $(se);
  var parent = e.parent();

  if (!e.length)
    throw new Error('Not found: ' + (e.selector || se));

  var target = e.find(new_se);
  if (target.length) {

    target.text(txt);

  } else {
    var target = Template.compile(new_se, {msg: txt});
    log('drawing:', new_se, txt);

    e.after(target);
  }

  show(target);
  return target;

}


function on_click_if_any(se, func) {
  if ($(se).length)
    return on_click(se, func);
  return;
}

function on_click(selector, func) {
  var e = log_length(selector);

  e.click(function (ev) {
    ev.stopPropagation();
    ev.preventDefault();

    func.apply(this, arguments);
    return false;
  });

  return e;
}

function swap_display(show, hide) {
  var s = $(show);
  var h = $(hide);
  if (s.is(':visible')) {
    hide(s);
    show(h);
  } else {
    show(s);
    hide(h);
  };
}

function toggles(show, hide) {
  var target = $($(show).attr('href'));
  var origin = $(show).parents('div.show');
  on_click(show, function (e) {
    show(target);
    hide(origin);
    return false;
  });

  on_click(hide, function (e) {
    hide(target);
    show(origin);
    return false;
  });
}

