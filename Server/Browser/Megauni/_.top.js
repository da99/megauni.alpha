
/* jshint strict: true, undef: true */
/* global Dum_Dum_Boom_Boom, _, App, log, $, dom_id, is_empty, split_on, describe_reduce  */
/* global be, is_function, combine */


window.template          = Dum_Dum_Boom_Boom.browser.data_do.template;
window.is_empty          = Dum_Dum_Boom_Boom.common.base.is_empty;
window.log               = Dum_Dum_Boom_Boom.common.base.log;
window.be                = Dum_Dum_Boom_Boom.common.base.be;
window.is_function       = Dum_Dum_Boom_Boom.common.base.is_function;
window.combine           = Dum_Dum_Boom_Boom.common.base.combine;
window.describe_function = Dum_Dum_Boom_Boom.common.base.describe_reduce;

var on_send = not_ready_yet("on_send");
var on_respond_ok = not_ready_yet("on_respond_ok");
var App = Dum_Dum_Boom_Boom.App;

App("send message", {"dom-change": true});
