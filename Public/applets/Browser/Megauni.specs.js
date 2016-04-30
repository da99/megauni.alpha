
/* jshint strict: true, undef: true */
/* global Dum_Dum_Boom_Boom, _, App, log, $, dom_id, is_empty, split_on, describe_reduce  */
/* global be, is_function, combine */


window.template    = Dum_Dum_Boom_Boom.browser.data_do.template;
window.is_empty    = Dum_Dum_Boom_Boom.common.base.is_empty;
window.log         = Dum_Dum_Boom_Boom.common.base.log;
window.be          = Dum_Dum_Boom_Boom.common.base.be;
window.is_function = Dum_Dum_Boom_Boom.common.base.is_function;
window.combine     = Dum_Dum_Boom_Boom.common.base.combine;

var on_send = not_ready_yet("on_send");
var on_respond_ok = not_ready_yet("on_respond_ok");
var App = Dum_Dum_Boom_Boom.App;

App("send message", {"dom-change": true});




function hide(data) {
  "use strict";
  if (Dum_Dum_Boom_Boom.common.base.is_empty(data.args)) {
    $('#' + data.dom_id).hide();
    return;
  }

  return Dum_Dum_Boom_Boom.browser.dom.hide(data);
} // === mu_hide



function key_exists(data) {
  "use strict";

  var copy_value = Dum_Dum_Boom_Boom.common.base.copy_value;
  var KEY = data.args[0];
  var FUNC = data.args[1];
  var ON_TRUE = copy_value(data);
  var ON_FALSE = copy_value(data);

  ON_TRUE.args = [KEY];
  ON_FALSE.args = ['!' + KEY];

  window[FUNC](ON_TRUE);
  window[FUNC](ON_FALSE);

  return true;
} // === key_exists




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

  log(name);
  function _not_ready_yet_(data) {
    log("Not ready: " +  name);
    return data;
  }

  return _not_ready_yet_;
}




function on_click(data) {
  var ARGS = data.args.slice(1);

  var FUNC = describe_reduce(
    "Getting function for on_click",
    window[data.args[0]],
    be(is_function)
  );

  $('#' + data.dom_id).on('click', function _on_click_(e) {
    e.stopPropagation();
    FUNC(combine(data, {args: ARGS}));
  });

} // === function



function send_form(data) {
  return not_ready_yet("send_form")(data);
} // === send_form



function send_message(data) {
  var KEY       = data.args[0];
  var CLEAN_KEY = _.trimStart(KEY, '!');
  var msg       = {};

  if (CLEAN_KEY !== KEY) // "KEY" !== "!KEY"
    msg[CLEAN_KEY] = false;
  else
    msg[CLEAN_KEY] = true;

  App("send message", msg);
} // send_message


