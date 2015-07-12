"use strict";


// ================================================================
// ==== On dom load,
// ================================================================
$(function () {

  $('#Out_Rooms div.room').each(function (i, e) {
    Chat_Room.new(e);
  });

});


// ================================================================
// ================== Events ======================================
// ================================================================

on('screen name', function (o) {
  Chat_Room.new(o.screen_name, o.screen_name);
});

on('before submit  #Create_Chat_Room_Seat', function (o) {
  var name = o.data.chat_room = canonize_screen_name(o.data.chat_room);
  var room = Chat_Room.find(name);
  if (room) {
    room.enter();
    o.flow.stop();
    o.form.make_like_new();
    return;
  }
})

on('before success #Create_Chat_Room_Seat', function (o) {
  o.flow.stop();
  o.form.make_like_new();

  Chat_Room.new(o.data.chat_room, o.data.owner)
  .enter();
});


// ================================================================
// ================== Main Object and Helpers =====================
// ================================================================


var Chat_Room = function () {};
Chat_Room.rooms = {};

// ================== Helpers =====================================

Chat_Room.find = function (u) {
  var name = (_.isString(u)) ? canonize_screen_name(u) :
    $(u).parent('div.room')
  .find('input[name="chat_room"]')
  .val();

  return Chat_Room.rooms[name];
};

Chat_Room.enter = function () {
  return Chat_Room.find(this).enter();
};

Chat_Room.leave = function () {
  return Chat_Room.find(this).leave();
};


// ================== Main Functions ==============================
Chat_Room.new = function (raw_name, raw_o_name) {

  var old_dom = null;

  if (!_.isString(raw_name)) {
    old_dom    = $(raw_name);
    raw_name   = old_dom.find('input[name="chat_room"]').val();
    raw_o_name = old_dom.find('input[name="owner"]').val();
  }

  var name   = canonize_screen_name(raw_name);
  var o_name = canonize_screen_name(raw_o_name);

  var old = Chat_Room.find(name);
  if (old)
    return old;

  var room    = new Chat_Room;
  room.name   = name;
  room.o_name = o_name;
  room.data   = {
    chat_room : name,
    owner     : o_name
  };

  Chat_Room.rooms[name] = room;
  room.is_in = false;

  room.draw_out(old_dom);
  room.draw_in();

  return room;
};

Chat_Room.prototype.draw_out = function (old_dom) {
  if (old_dom) {
    var o = $(old_dom);
  } else {
    var o = Template.compile('#Chat_Rooms div.room.out', this.data);
    $('#Out_Rooms div.rooms').prepend(o);
  }

  on_click(o.find('a.enter'), Chat_Room.enter);
  this.out = o;
  return this;
};


Chat_Room.prototype.draw_in = function () {
  var room_in = Template.compile('#Chat_Rooms div.room.in', this.data);
  hide(room_in);
  $('#In_Rooms div.rooms').prepend(room_in);

  on_click(room_in.find('a.leave'), Chat_Room.leave);
  this.in = room_in;
  return this;
};


Chat_Room.prototype.enter = function () {

  if (APP_ERROR)
    return;

  var me = this;

  if (me.is_in)
    return me;

  me.out.addClass('loading');

  post("/chat_room/enter", me.data, function (err, result) {
    me.out.removeClass('loading');
    if (err || !result.success) {
      emit('chat room msg', {
        is_official: true,
        is_error:    true,
        body: "Try again later. Chat room unavailable: " + me.name
      });
      log(err, result);
      return;
    }

    emit('chat room msg', {
      is_official: true,
      body: result.msg
    });

    me.out.hide();
    me.in.show();
    me.is_in = true;
    emit('after enter chat room', {room: me});
  });

  return me;
}; // === enter


Chat_Room.prototype.leave = function () {
  var me = this;

  if (!me.is_in)
    return this;

  me.in.addClass('loading');

  var fin = function () {
    me.in.removeClass('loading');
    me.in.hide();
    me.out.show();
    me.is_in = false;

    emit('chat room msg', {
      is_official: true,
      body: "You're officially out of: " + me.name
    });

    emit('after leave chat room', {room: me});
  };

  post('/chat_room/leave', me.data, function (err, result) {
    if (err || !result.success) {
      setTimeout(fin, 3500);
      return;
    }

    fin();
  });

  return this;
}; // === leave






