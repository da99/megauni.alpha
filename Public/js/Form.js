"use strict";

$(function () {
  $('form').each(function (i, e) {
    var id = $(e).attr('id');
    if (!id)
      throw new Error('Form does not have id: ' + $(e).html());
    form('#' + id);
  });
});

// ================================================================
// ================== Form DSL ====================================
// ================================================================


function is_filled(se) {
  var form   = $(se);
  var inputs = form.find('input[type="text"], textarea');
  if (inputs.length < 1)
    return true;
  var i = _.find(inputs, function (e) {
    return $.trim($(e).val()).length > 0;
  });

  return !!i;
}

function form_to_json(selector) {
  var e = $(selector).closest('form');
  if (!e.length) {
    log("No form found for: " + selector);
    return;
  }
  return $(e).serializeJSON();
}


function form(selector) {
  if (arguments.length > 1)
    throw new Error("Unknown arguments: " + arguments[1]);
  var f = OK_FORM.new(selector);
  return f;
}

// ================================================================
// ================== Form Implementation =========================
// ================================================================


var OK_FORM = function () {};
var FORMS = {};


OK_FORM.new = function (raw_se) {
  var se = $.trim(raw_se);

  if (se.indexOf('#') !== 0 || se.length < 2)
    throw new Error("Invalid dom id: " + se);

  if (FORMS[se])
    throw new Error('Form was duplicated: ' + selector);

  FORMS[se] = true;

  var f             = new OK_FORM;
  f.dom             = $(se);
  f.dom_id          = se;
  f.default_err_msg = "Okdoki.com is having some " +
    "trouble processing your request. Try again later in a few minutes.";


  create_event('cancel '        + f.dom_id);
  create_event('before submit ' + f.dom_id);
  create_event('loading '       + f.dom_id);
  create_event('before success '+ f.dom_id);
  create_event('after success ' + f.dom_id);
  create_event('invalid '       + f.dom_id);
  create_event('error   '       + f.dom_id);

  on_click_if_any(f.dom.find('a.cancel'), _.bind(f.cancel, f));
  on_click(f.dom.find('button.submit'),   _.bind(f.submit, f));

  log("Created form: ", f.dom_id);
  return f;
};


OK_FORM.prototype.cancel = function () {
  this.make_like_new();
  if ( !emit('cancel ' + this.dom_id) )
    return false;
  return this.make_like_new();
};


// ================================================================
// ================== Drawing  ====================================
// ================================================================

OK_FORM.prototype.reset_status = function () {
  hide( this.loading() );
  show( this.buttons() );
  hide( this.errors() );
  hide( this.success() );
  return this;
};

OK_FORM.prototype.buttons = function () {
  return this.dom.find('div.buttons');
};

OK_FORM.prototype.loading = function () {
  return this.dom.find('div.loading');
};

OK_FORM.prototype.errors = function () {
  return this.dom.find('div.errors');
};

OK_FORM.prototype.success = function () {
  return this.dom.find('div.success');
};

OK_FORM.prototype.draw_success = function (msg) {
  if (!msg)
    throw new Error("No success message for: " + this.dom_id);

  this.reset_status();

  after(this.buttons(), 'div.success', msg);

  return this;
};

OK_FORM.prototype.draw_errors = function (msg) {
  msg || (msg = this.default_err_msg);

  this.reset_status();

  after(this.buttons(), 'div.errors', msg);

  return this;
};

OK_FORM.prototype.make_like_new = function () {
  var f = this;
  f.reset_to_submit_more();
  hide(f.success());
  return f;
};


OK_FORM.prototype.reset_to_submit_more = function() {
  var f = this;

  f.dom[0].reset();

  show(f.buttons());
  hide(f.loading());
  hide(f.errors());

  show(f.buttons());

  return f;
};


OK_FORM.prototype.submit = function () {

  var f   = this;
  var meta = {
    form : f,
    url  : f.dom.attr('action'),
    data : form_to_json(f.dom)
  };

  if (!is_filled(f.dom_id))
    return false;

  if (stopped_emit('before submit ' + f.dom_id, meta))
    return false;

  if (emit('loading ' + f.dom_id, meta)) {
    // === Show loading feedback. ===
    hide( f.buttons() );
    hide( f.errors()  );
    hide( f.success() );

    after(f.buttons(), 'div.loading', 'processing...');
  }

  // === POST it. ===
  post(meta.url, meta.data, function (err, raw) {

    if (err) {

      log("Form http error: ", f.dom_id, err, raw);

      if (stopped_emit('error ' + f.dom_id, {err: err, raw: raw}))
        return;

      if (_.isNumber(err) && err > 0)
        f.draw_errors();
      else if (err === true) {
        var o = to_json_result(raw);
        f.draw_errors(o.msg || "Website not available right now. Try again later.");
      } else
        f.draw_errors();

      return ;
    }

    var data = (typeof raw === 'string') ? to_json_result(raw) : raw;

    log("Form results: " + f.dom_id, data.msg);

    var meta = {data: data, form: f, raw: raw};

    // === invalid ===
    if (!data.success) {
      if (stopped_emit('invalid ' + f.dom_id, meta))
        return;
      f.draw_errors(data.msg);
      return;
    }

    // ==== success ====
    if (emit('before success ' + f.dom_id, meta)) {
      f.reset_to_submit_more();
      f.draw_success(meta.data.msg);
    }

    emit('after success ' + f.dom_id, meta);
  }); // === POST it.

}; // === submit


