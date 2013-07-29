"use strict";

// ======================================
//
// Required DOM:
//   #Messages
//
// ======================================

var Headline_Read = {
  MAX       : 300,
  DOM       : $('#Headlines'),
  Write     : $('#Headline_Create')
};

create_event('headline');

// === Submitting a msg ===
on('before success #Headline_Create', function (o) {
  o.flow.stop();
  o.form.reset_status();
  Headline_Read.Write.find('textarea').val("");
  emit('headline', o.data.headline);
});


// === Add headline to DOM
on('headline', function (msg) {
  var template_msg = _.defaults(msg, {
    dom_id : msg.dom_id || ('m' + msg.id + '_' + (new Date).getTime()),
    author : msg.author || '',
    body   : msg.body || ''
  });

  var o = Template.compile('div.headline.msg', template_msg);

  if (msg.is_clean_body_html)
    o.find('div.body').html(msg.body_html);

  if (msg.link) {
    var a = $('<a/>');
    a.attr('href', msg.link);
    a.text('Read more...');
    o.find('div.body').append(a);
    o.find('span.said').text('Feed: ');
  }

  o.find('a').attr('target', '_blank');
  Headline_Read.DOM.prepend(o);
});

// === Add CSS classes.
on('headline', function (msg) {
  var o = $('#' + msg.dom_id);

  if (msg.is_official)
    o.addClass('official');

  if (msg.is_me) {
    o.addClass('me');
    o.find('span.name').text(o.find('span.name').text() + ' (me)');
  }

  if (msg.is_error)
    o.addClass('error');

  if (msg.is_official || msg.is_error)
    o.find('div.meta').remove();
});

// === Remove extra messages
on('headline', function (msg) {
  var list = Headline_Read.DOM.find('div.msg');
  if (list.length > Headline_Read.MAX)
    list.last().remove();
});

// ======  Entering/Leaving Chat Rooms ====
// on('after enter chat room', function (o) {
  // var menu = Headline_Read.Room_Menu;
  // var opt  = $('<option></option>');
  // opt.attr('value', o.room.name);

  // opt.text(o.room.name);
  // menu.prepend(opt);
  // if (menu.find('option').length > 1)
    // menu.parent('span.to').show();
  // else
    // menu.parent('span.to').hide();
  // Headline_Read.Write.show();

  // CHAT_MSG_LOOP = true;
// });

// on('after leave chat room', function (o) {
  // var menu = Headline_Read.Room_Menu;

  // menu.find('option').each(function (i, opt) {
    // if ($(opt).attr('value') === o.room.name)
      // $(opt).remove();
  // });

  // if (menu.find('option').length < 2)
    // menu.parent('span.to').hide();

  // if (menu.find('option').length < 1) {
    // Headline_Read.Write.hide();
    // CHAT_MSG_LOOP = false;
  // }

// });


// function get_msgs() {
  // if (window.hasOwnProperty('APP_ERROR') && APP_ERROR)
    // return;

  // post("/heart_beep", {start_at: CHAT_MSG_OLDEST_EPOCH}, function (err, result) {
    // if (err)
      // return;
    // add_these_pending_msgs(result.msg_list || []);
    // setTimeout(get_msgs, 1000 * 10);
  // });
// }

// function add_these_pending_msgs(list) {
  // PENDING_CHAT_MSG = PENDING_CHAT_MSG.concat(list);
// }

// function draw_all_msgs() {
  // var m = PENDING_CHAT_MSG.shift();
  // if (!m || (m.dom_id && $('#' + m.dom_id).length))
    // return;
  // emit('chat room msg', m);
// }


// get_msgs();

// setInterval(draw_all_msgs, 1500);


