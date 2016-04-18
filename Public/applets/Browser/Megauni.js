/* jshint strict: true, undef: true */
/* global App, log */


function not_ready_yet(name) {
  "use strict";

  function _not_ready_yet_(data) {
    log("Not ready: " +  name);
    return data;
  }

  return _not_ready_yet_;
}

var on_send = not_ready_yet("on_send");
var on_respond_ok = not_ready_yet("on_respond_ok");

App("send message", {"dom-change": true});
