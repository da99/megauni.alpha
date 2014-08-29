
var Contacts = function (selector) {
  this.home       = $(selector);
  this.list       = this.home.find('div.contacts');
  this.loading    = this.home.find('div.loading');
  this.no_records = this.home.find('div.no_records');
  this.events     = {
    after_success_read: []
  };
}

Contacts.new = function (selector) {
  return (new Contacts(selector));
};

Contacts.prototype.push_event = function (name, func) {
  var me = this;
  if (!me.events[name])
    throw new Error('unknown event: ' + name);
  me.events[name].push(func);
};

Contacts.prototype.run_event = function (name) {
  var me = this;
  $.each(me.events[name], function(i, f) {
    f(me);
  });
};

Contacts.prototype.read = function (opts) {
  var me = this;
  var run_it = true;

  if (opts) {
    $.each(opts, function (k, v) {
      switch (k) {
        case 'wait':
          setTimeout(function () {me.read();}, v);
        run_it = false;
          break;
        case 'after_success':
          me.push_event(k+'_read', v);
        break;
        default:
          throw new Error('Programmer error: Unknown Contacts#read option: ' + k);
      };
    });
  }

  if (!run_it)
    return null;

  var o = {
    type        : 'POST',
    url         : Box.base_url + "/contacts/online",
    cache       : false,
    contentType : 'application/json',
    data        : JSON.stringify({"_csrf": csrf_token_val()}),
    dataType    : 'json',
    success     : function (resp, stat) {
      log(resp, stat);

      if (is_dev && (!resp.menu || $.isEmptyObject(resp.menu))) {
        resp.menu = ({
          zebra       : ['go99'],
          mike_rogers : ['go99'],
          okdoki      : ['dos'],
          jeff_tucker : ['go99', 'dos'],
          Lew_Rock    : ['go99']
        });
      }

      The_Contacts.load(resp.menu || {});
      me.run_event('after_success_read');
    },
    error       : function (xhr, textStatus, errThrown) {
      log(textStatus, errThrown);
    }
  };

  $.ajax(o);
}

Contacts.prototype.first_load = function (menu) {
  return me.load(menu);
};

Contacts.prototype.load = function (menu) {
  var me   = this;

  if ($.isEmptyObject(menu)) {

    if (me.home.find('div.contact:first').length === 0)
      me.no_records.show();
  } else {

    $.each(menu, function (key, arr) {
      var ele  = $('<div class="contact">' +
                   '<div class="screen_name"></div>' +
                   '<div class="as">' +
                   '<span class="intro">From:</span>' +
                   '<span class="screen_names"></span>' +
                   '</div>' +
                   '</div>');

      var link = new_target( $('<a></a>').text(key).attr('href', "/info/" + key) );
      ele.find('div.screen_name').append(link);
      ele.find('span.screen_names').text(arr.join(', '));
      me.list.append(ele);
    });

    me.no_records.hide();
  }

  me.loading.hide();
  return me.list;
};

Contacts.prototype.sort = function () {
  chatters = _.uniq(chatters).sort();
  $("#contacts_list").empty();

  $.each(chatters.sort(), function (i, val) {
    $('#' + add_contact(val)).addClass('chatty');
  });
};


