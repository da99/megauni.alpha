"use strict";

var Applet = {

  data : {
    default: null
  },

  nodes : [
  ],

  log : function (str) {
    if (window.console) {
      return console.log.apply(console, arguments);
    }
  },

  _id : -1,

  id : function (o, prefix) {
    if (_.isString(o.id) &&  !_.isEmpty(o.id))
      return o.id;

    if (o.attr && _.isString(o.attr('id')) && !_.isEmpty(o.attr('id')))
      return o.attr('id');

    Applet._id = Applet._id + 1;
    var new_id = (prefix || 'id_for_applet') + '_' + Applet._id.toString();
    $(o).attr('id', new_id);
    return new_id;
  },

  actions: [
    'show_if',
    'hide_if'
  ],

  compile_script_tag : function (raw_script) {

    var script    = $(raw_script);
    var script_id = Applet.id(raw_script);
    $(script.html()).each(function (i, raw_child) {

      var child = $(raw_child);
      _.each(Applet.actions, function (name) {

        var val = child.attr(name);
        if (!val)
          return;

        Applet.nodes.push({
          id:     Applet.id(child, script_id),
          action: name,
          value:  val
        });

        child.removeAttr(name);

        switch (name) {
          case 'show_if':
            if (Applet.data.default[val])
              child.show();
            else
              child.hide();
            break;
          case 'hide_if':
            if (Applet.data.default[val])
              child.hide();
            else
              child.show();
            break;
          default:
            Applet.log('I do not know what to do on: ' + name);
        } // === switch

      }); // === each Applet action

      script.after(child);
    });

  }, // === compile_script

  run: function (raw_data) {
    if (!Applet.data.default) {
      var data = {};
      _.each(raw_data, function (v, k) {
        data[k] = v;
        if (!_.startsWith(k, '!') && !_.has(raw_data, '!' + k))
          data['!'+k] = !v;
      });

      Applet.data.default = data;
      $('script[type="applet/megauni"]').each(function (i, o) {
        Applet.compile_script_tag(o);
      });
    }
  }
};

$(function () {
  Applet.run({"logged_in?": false});
});
