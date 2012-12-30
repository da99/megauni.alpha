

var Forms = {};

Forms.callbacks = {};

Forms.Submit_Button = function (id, callbacks) {
  var button  = $('#' + id);
  var form = button.closest('form');

  if (form.attr('id') && form.attr('id') != '' && callbacks) {
    Forms.callbacks[form.attr('id')] = callbacks;
  };

  button.click(function (e) {
    e.preventDefault();
    form.children('div.errors').remove();
    form.children('div.success').remove();
    form.addClass('loading');
    setTimeout(function () {
      Forms.Submit(form);
    }, 500);
  });

  return button;
};

Forms.Submit = function (form) {
  var ajax_o = Forms.Default_Ajax_Options(form);
  log(ajax_o);
  $.ajax(ajax_o);
  return form;
};

Forms.Success = function (form, resp, stat) {
  if (stat !== 'success') {
    Forms.Errors(form, "Unknown error.");
    return form;
  };

  if (!resp.success) {
    Forms.Errors(form, resp.msg);
    return form;
  };

  Forms.call_callback(form.attr('id'), 'before_success');
  form.children('div.fields').hide();
  form.removeClass('loading');
  log(stat);
  var e = $('<div></div>');
  e.addClass('success');
  e.text(resp.msg);
  form.prepend(e);

  Forms.call_callback(form.attr('id'), 'after_success');
  return form;
};

Forms.Errors = function (form, msg) {
  form.removeClass('loading');
  var e = $('<div></div>');
  e.addClass('errors');
  e.text(msg);
  form.append(e);

  return form;
};

Forms.Default_Ajax_Options = function (raw_form) {
  var form = $(raw_form);
  var obj = {};
  $.each(form.serializeArray(), function (i, ele) {
    obj[ele.name] = ele.value;
  });
  return { type: 'POST',
    url : window.location.origin + form.attr('action'),
    cache: false,
    contentType: 'application/json',
    data : JSON.stringify(obj),
    dataType: 'json',
    success: function (resp, stat) {
      Forms.Success(form, resp, stat);
    },
    error: function (xhr, textStatus, errThrown) {
      Forms.Errors(form, textStatus + ': ' + (errThrown || "Check internet connection. Either that or OKdoki.com is down.") );
    }
  };
};

Forms.call_callback = function (id, name) {
  var cb = Forms.callbacks[id];
  log(Forms.callbacks)
  if (!cb)
    return false;

  var func = cb[name];
  if (!func)
    return false;

  return func();
};




