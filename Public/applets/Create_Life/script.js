"use strict";

create_event('screen name created');

var Create_Life = {
  sn_new: [],
  new_opt: function (sn) {
    var o = $('<option></option>');
    o.attr('value', sn);
    o.text(sn);
    return o;
  }
};

on('screen name', function (m) {
  var sn = m.screen_name;
  // === Add new name to SELECT menus.
  $('select[name="as_this_life"]').each(function (i, e) {
    $(e).prepend(Create_Life.new_opt(sn));
    $(e).val(sn);
    $(e).parent('span.as_this_life').show();
  });
});

on('screen name', function (m) {
  $('#Create_Life ul.screen_names').prepend(Template.compile('li.screen_name', {name: m.screen_name}));
});


on('after success #Create_Screen_Name', function (result) {

  var sn = result.data.screen_name;
  Create_Life.sn_new.push(sn);

  emit('screen name', {screen_name: sn});
  return sn;

});

on('template compiled', function (o) {
  if (Create_Life.sn_new.length === 0)
    return;

  $(o.dom).find('select[name="as_this_life"]').each(function (i, e) {
    _.each(Create_Life.sn_new, function (n) {
      $(e).prepend(Create_Life.new_opt(n));
    });
  });
});




