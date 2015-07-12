"use strict";

function temp() {

  var CMDS = {
    stack : [],
    "draw" : function (e) {
      this.dom_list().append(e);
    },

    "draw settings box" : function (args) {
      this.draw();
      var id   = args[0];
      var name = args[1];
      var box = $('<div class="box"><div class="content"><div class="on_off">' +
                  '<a class="on" href="#on">On</a>' +
                  '<a class="off" href="#off">Off</a>' +
                  '<span class="name"></span>' +
                  '<input name="file_name" type="hidden" value="" />' +
                  '</div></div></div>');
      box.find('span.name').text(name);
      box.find('input[name="file_name"]').val(id);
      box.attr('id', 'feature_pack_' + id);
      this.draw(box);
      this.stack.push(box);
    },

    'is on' : function () {
      _.last(this.stack).addClass('is_on');
    },

    'is genius': function () {
      this.dom_list_genius().append( _.last(this.stack) );
    },

    draw_these : function (arr) {
      var i = 0;
      var max = arr.length;
      while (i < max) {
        var cmd = arr[i];
        var args = arr[i + 1];
        CMDS[cmd](args);
        i = i + 2;
      }
      $('#Toggle_Feature_Packs div.settings_list').children('div.loading').hide();
    },

    dom_list_genius : function () {
      return $($('#Toggle_Feature_Packs div.settings_list')[1]);
    },

    dom_list : function () {
      return $($('#Toggle_Feature_Packs div.settings_list')[0]);
    }

  };

  post("/settings/list", {}, function (err, result) {
    if (err)
      return log('Failed to get settings list: ', err);
    CMDS.draw_these(result);
  });

}; // === post


