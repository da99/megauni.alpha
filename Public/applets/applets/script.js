"use strict";

var Applet = {

  data : {
    default: null
  },

  bool : function () {
    var key, o;
    var arr = _.toArray(arguments);

    if (arr.length === 1) {
      o = Applet.data.default;
      key = arr[0];
    } else {
      o = arr[0];
      key = arr[1];
    }

    if (!_.has(o, key))
      throw new Error('Key not found: ' + key);

    return !!o[key];
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
            if (Applet.bool( val ))
              child.show();
            else
              child.hide();
            break;
          case 'hide_if':
            if (Applet.bool( val ))
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
    var data = {};
    _.each(raw_data, function (v, k) {
      data[k] = v;
      if (!_.startsWith(k, '!') && !_.has(raw_data, '!' + k))
        data['!'+k] = !v;
    });

    if (!Applet.data.default) {
      Applet.data.default = data;
      $('script[type="applet/megauni"]').each(function (i, o) {
        Applet.compile_script_tag(o);
      });
    } else {
      _.each(Applet.nodes, function (o) {
        if (!_.has(data, o.value))
          return;

        switch (o.action) {
          case 'show_if':
            if (data[o.value])
              $('#' + o.id).show();
            else
              $('#' + o.id).hide();
          break;

          case 'hide_if':
            if (data[o.value])
              $('#' + o.id).hide();
            else
              $('#' + o.id).show();
          break;

          default:
            throw new Error('I don\'t know about: ' + o.action);
        }; // === case
      });
    }
  }
};

$(function () {
  Applet.run({"logged_in?": false});
});
