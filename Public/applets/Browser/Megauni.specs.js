
/* jshint strict: true, undef: true */
/* global Dum_Dum_Boom_Boom, App, log, $, dom_id, is_empty, split_on, describe_reduce  */

var on_send = not_ready_yet("on_send");
var on_respond_ok = not_ready_yet("on_respond_ok");
App("send message", {"dom-change": true});





function hide(data) {
  "use strict";
  if (is_empty(data.args)) {
    $('#' + data.dom_id).hide();
    return;
  }

  return Dum_Dum_Boom_Boom.browser.dom.hide(data);
} // === mu_hide




function key_relative_to_dom(target, str) {
  "use strict";

  var pieces = describe_reduce(
    "Transforming mu key",
    str,
    split_on('.')
  );

  if (pieces.size !== 2)
    return str;

  var FIND   = pieces[0];
  var KEY    = pieces[1];
  var PARENT = target.closest(FIND);

  if (is_empty(PARENT))
    throw new Error("Key relative to dom not found: " + str);

  var DOM_ID = dom_id(PARENT);
  return DOM_ID + '_' + KEY;
} // === mu_key




function not_ready_yet(name) {
  "use strict";

  function _not_ready_yet_(data) {
    log("Not ready: " +  name);
    return data;
  }

  return _not_ready_yet_;
}



