

// ================================================================
// ================== WWW_Applet ==================================
// ================================================================


// Example:
//  WWW_Applet.run_these(result.bots);
//
var WWW_Applet = function () { };

WWW_Applet.run_these = function (list) {
  _.each(list, function (o) {
    log("Running WWW applet: ", o.screen_name)
    if (o.o_code.life)
      WWW_Applet.run(o, o.o_code.life);
    else
      log("Skipping applet because life property not found.", o);
  });
};

WWW_Applet.Whitespace = /\s+/ig;
WWW_Applet.INVALID_CHARS = /[^a-zA-Z0-9]+/g;

WWW_Applet.canonize_function_name = function (str) {
  if (!_.isString(str))
    return str;
  return $.trim(str.toLowerCase().replace(WWW_Applet.Whitespace, ' '));
};

WWW_Applet.run = function (meta, o) {
  var a    = new WWW_Applet();
  a.meta   = meta;
  a.applet = o;
  a.stack  = [];
  a.dom_ns_string = a.meta.screen_name.replace(WWW_Applet.INVALID_CHARS, '_');
  a.run();
};

WWW_Applet.FUNC_NAMES = {};

// ================================================================
// ================== Helpers =====================================
// ================================================================

function define(str, func) {
  WWW_Applet.FUNC_NAMES[str] = func;
  return WWW_Applet;
}

WWW_Applet.INVALID_CSS_CHARS = /[^a-zA-Z0-9\#\_\-\ ]+/ig;

function css_attr(str) {
  return str.replace(WWW_Applet.INVALID_CSS_CHARS, '');
}

function css(ele, str, val) {
  return $(ele).css(str, css_attr(val));
}

// ================================================================
// ================== "Instance" Methods ==========================
// ================================================================

WWW_Applet.prototype.quit  = function (str, val) {
  var me = this;
  log(me.meta.screen_name, ' is quitting because ', str, val);
};

WWW_Applet.prototype.run = function () {
  var me = this;
  var cmds = me.applet.slice();
  while (cmds.length) {
    var call = WWW_Applet.canonize_function_name(cmds.shift());
    var args = cmds.shift();
    if (!_.isString(call))
      return me.quit("not a function name:", call);
    if (!WWW_Applet.FUNC_NAMES[call])
      return me.quit('function not found:', call);
    if (!_.isArray(args))
      return me.quit("not arguments:", args);
    WWW_Applet.FUNC_NAMES[call].apply(me, args);
  }
};

WWW_Applet.prototype.dom_ns = function (str) {
  var me = this;
  if (str === '#Sidebar')
    return str;
  return str.replace('#', '#' + me.dom_ns_string + '_');
};

WWW_Applet.prototype.dom_by_id = function (str) {
  var me = this;
  return $(me.dom_ns(str));
};

define("box", function (id) {
  var me = this;
  me.stack.push(me.dom_by_id(id));
  return me;
});

define('create box at top',  function (id) {
  var me = this;
  var box = $('<div class="box" />');
  box.attr('id', me.dom_ns(id).replace('#', ''));
  var last = _.last(me.stack);
  me.stack.push(box);
  last.prepend(box);

  return me;
});

define('list', function () {
  var me = this;
  me.stack.push(_.toArray(arguments));
  return me;
});

// From: http://stackoverflow.com/questions/5915096/get-random-item-from-array-with-jquery
define('random item', function () {
  var me = this;
  var list = _.last(me.stack);
  var item = list[Math.floor(Math.random()*list.length)];
  me.stack.push(item);
  return me;
});

define('is text of', function (id) {
  var me = this;
  var ele = $(me.dom_ns(id));

  ele.text(_.last(me.stack));
  me.stack.push(ele);
  return me;
});


_.each(['padding', 'font-size'], function (attr) {
  define(attr, function (val) {
    var me = this;
    css( _.last(me.stack), attr, val);
    return me;
  });
});

