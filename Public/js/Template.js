
"use strict";

$(function () {
  // Read templates (html) and save for later use.
  Template.html( $('#js_templates').html() );
});


// ================================================================
// ================== Events ======================================
// ================================================================

create_event('template compiled');


// ================================================================
// ================== Templates ===================================
// ================================================================


var Template = {

  html : function (html) {
    if (html)
      this._html = $(html).wrap('<p/>').parent();
    if (!this._html)
      throw new Error('Template HTML not ready.');
    return this._html;
  },

  read : function (se) {
    var t = Template.html().find(se);
    if (!t.length)
      throw new Error('Template not found: ' + se);
    return outer_html(t);
  },

  read_content : function (se) {
    return $(this.read(se)).text();
  },

  compile: function (se, data) {
    var txt = $(this.read(se));
    var me  = this;

    _.each(data, function (v, k) {
      txt.closest('.' + k).text(v);
      txt.find('.' + k).text(v);
    });


    var o = $(txt);
    emit('template compiled', {dom: o});
    return o;
  }

}; // === Template




