
$(function () {

  $('textarea').focus( function () {
    var txt = $(this).val();
    if (txt === 'Type your question here.' || txt === 'Type your reason here.') {
      $(this).val('');
      $(this).removeClass('blurred');
    };
  });

  $('#control_priv').change(function () {
    var form     = $(this).closest('form');
    var textarea = form.find('div.specify');
    var submit   = form.find('button.submit');

    submit.show();

    if ($(this).val() === 'S')
      textarea.show();
    else
      textarea.hide();
  });

  Forms.Submit_Button('#form_homepage_priv button.submit', {
    before_submit : function (opts) {
      // var form     = $(this).closest('form');
      // var textarea = form.find('div.specify');
      // var submit   = form.find('button.submit');
      // var box      = $(this).closest("div.options");
    }, after_success: function () {
      $('#form_homepage_priv div.fields').show();
      $('#form_homepage_priv button.submit').hide();
    }
  });

  $('#show_form_create_content').click(function (e) {
    e.preventDefault();
    $(this).hide();
    $('#form_create_content').show();
  });

  Forms.Submit_Button('#form_trash_screen_name button.submit', {
    after_success: function () {
      $('#form_trash_screen_name').addClass('trashed');
    }
  });

  Forms.Undo_Button('#form_trash_screen_name button.undo', {
    after_success: function () {
      $('body').removeClass('trashed');
    }
  });

  Edit_able_s.new('#update_at');
  Edit_able_s.new('#update_bot');

  Forms.Submit_able('#form_update_contact');
  Forms.Submit_able('#form_update_about');
  Forms.Submit_able('#form_create_question', {
    after_success: function (resp) {
      resp.rows[0].html_order = 'prepend';
      qa_record('row', resp.rows[0]);
    }
  });
  Forms.Submit_able('#form_create_cheer_or_jeer', {
    before_submit: function (o) {
      o.url = o.url.replace('/cheer', '/' + $('#form_create_cheer_or_jeer select[name="section_name"]').val());
    },
    after_success: function (resp) {
      resp.rows[0].html_order = 'prepend';
      boo_record('row', resp.rows[0]);
    }
  });

  var base_path = window.location.pathname.replace(/\/$/, '');
  Records.get(base_path + '/list/qa', '#qa', qa_record);
  Records.get(base_path + '/list/cheers-boos', '#boos', boo_record);
  Records.get(base_path + '/list/posts', '#latest', latest_record);

  create_show_button('#scientist_settings div.body', 'Edit Settings', '#scientist_settings div.forms');

});

function screen_name(txt) {
  var n = window.location.pathname.replace('/', ' ').trim().split('/').pop();
  return txt.replace("{screen_name}", n);
}

function create_show_button(container, txt, target) {
  var button = $('<button></button>');
  button.text(screen_name(txt));
  button.addClass('show');
  $(container).append(button);
  button.click(function (e) {
    e.preventDefault();
    log($(target))
    $(target).show();
    $(e.target).remove();
  });

  return $(button);
}

function qa_record(type, o) {
  var id = '#qa';
  switch (type) {
    case 'no_rows':
      Records.no_rows(id, o.msg);
    break;
    case 'row':
      var q = $('<div class="record"></div>');
      q.text(o.author_screen_name + ' asked: ' + o.body);
      $(id + ' div.body  div.records')[o.html_order || 'prepend'](q);
    break;
    default:
      Records.error(id, o);
  };
};

function boo_record(type, o) {
  var id = '#boos';
  switch (type) {
    case 'no_rows':
      Records.no_rows(id, o.msg);
    break;
    case 'row':
      var q = $('<div class="record"></div>');
      var section_name = ((o.section_name === 'jeer') ? 'boo' : 'cheer');
      q.text(section_name + ' from ' + o.author_screen_name + ': ' + o.body);
      $(id + ' div.body  div.records')[o.html_order || 'prepend'](q);
    break;
    default:
      Records.error(id, o);
  };
};

function latest_record(type, o) {
  var id = '#latest';
  switch (type) {
    case 'no_rows':
      Records.no_rows('#latest', o.msg);
      break;
    case 'row':
      var q = $('<div class="record"></div>');
    q.text(o.body);
    $(id + ' div.body div.records').append(q);
    break;
    default:
      Records.error(id, o);
  };
};

var Records = {};

Records.error = function (selector, o) {
  $(selector + ' div.body div.loading_rows ').remove();
  if (!o || !o.msg) {
    log("Uknown record missing error msg: ");
    log(o);
    return false;
  }

  var target = $(selector);
  var block  = target.children('div.body');
  var err    = $('<div class="error"></div>');
  err.text(o.msg);
  block.children('div.error').remove();
  block.prepend(err);

  return err;
};

Records.get = function (url, selector, callback) {
  var o = Records.default_ajax_options(url, selector, callback);
  return $.ajax(o);
};

Records.no_rows = function (selector, msg) {
  var div = $('<div class="no_rows"></div>');
  div.text(msg);
  var parent = $(selector + ' div.body');

  $(selector + ' div.no_rows').remove();
  $(selector + ' div.rows').remove();
  parent.prepend(div);
};

Records.default_ajax_options = function (url, selector, callback) {
  return { type : 'GET',
    url         : window.location.href + url,
    cache       : false,
    dataType    : 'json',
    success     : function (resp, stat) {
      $(selector + ' div.body div.loading_rows ').remove();
      $(selector + ' div.body div.records ').remove();
      $(selector + ' div.body ').prepend($('<div class="records"></div>'));

      if (resp.success) {
        if (resp.rows.length == 0)
          callback('no_rows', resp, stat);
        else {
          var records = resp.rows.slice();
          while (records.length > 0) {
            callback('row', records.pop());
          };
        }
      } else {
        callback('fail', resp, stat );
      }
    },
    error : function (xhr, textStatus, errThrown) {
      var msg = textStatus + ' : ' + (errThrown || "Check internet connection. Either that or OKdoki.com is down.");
      callback('error', {msg: msg}, xhr, textStatus, errThrown);
    }
  }
};
