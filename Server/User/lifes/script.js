"use strict";

var old_err   = window.onerror;
var APP_ERROR = false;

window.onerror = function (errorMsg, url, lineNumber) {
  if (old_err)
    return old_err.apply(null, arguments);

  if (window.$) {
    var dom_id = "APP_ERROR_BIG_MSG";
    var o = ($('#' + dom_id).length) ? $('#' + dom_id) : $('<div/>');
    o.attr('id', dom_id);
    o.addClass('APP_ERROR');
    o.text("Unexpected error. Refresh this page.");
    $('body').prepend(o);
    window.scrollTo(0, 0);
  }

  if (console && console.log)
    console.log(arguments);

  APP_ERROR = arguments[0] || "unknown";
  return false;
};

// ===========================================
// TODO: Middle click should pass right
// through. Right now, it is over-ridden
// when it should not.
// ===========================================
function attach_console_link_click(e) {
  var href = $(e).attr('href');
  if (href.indexOf('/log') > -1 || href.indexOf('#') > -1 )
    return;

  on_click(e, function (ev) {
    var o = $(this);
    if (ev.which === 2 || Customer_Lifes.in_chat_rooms.length)
      window.open(o.attr('href'), '_blank');
    else
      window.location.href = o.attr('href');
  });

}


// ================ ON LOAD ======================
$(function () {
  // $('a').each(function (i, e) {
    // attach_console_link_click(e);
  // });

});

// on('template compiled' , function (o) {
  // $(o.dom).find('a').each(function (i, e) {
    // attach_console_link_click(e);
  // });
// });


// === When to open links in a new window.
var Customer_Lifes = {
  in_chat_rooms : []
};

on('after success #Create_Screen_Name', function (o) {
  window.location.href = o.data.href;
});

on('after enter chat room', function () {
  Customer_Lifes.in_chat_rooms.push(1);
});

on('after leave chat room', function () {
  Customer_Lifes.in_chat_rooms.pop();
});




