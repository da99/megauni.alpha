$(function () {

  toggles("#Message_Board div.show_write a", "#Write_Message a.cancel");
  // ============================================
  // ================ Post a message board msg...
  // ============================================
  form('#Write_Message', function (f) {
    f.at_least_one_not_empty('textarea');
    f.on_success(function (result) {
      f.find('div.success').hide();
      me_mb_msg(result.mb_msg);
      f.find('a.cancel').click();
    });
  });

  // ============================================
  // ================ Grab message board msgs....
  // ============================================
  get('/me/' + Screen_Name.screen_name() + '/message_board/msgs' , function (err, o) {
    var div_loading = $('#Message_Board div.msgs div.loading');

    if (err) {
      log(err);
      div_loading.addClass('errors');
      div_loading.removeClass('loading');
      div_loading.text("Messages could not be retrieved at this time. Try again later by refreshing this page.");
      return false;
    }

    div_loading.remove();
    mb_msg(o.list);
  });


}); // ==============================================

function me_mb_msg(o) {
  $('#Message_Board').find('div.msgs').prepend( Template.compile('div.me_msg', o) );
}


function mb_msg(o) {
  var sn = Screen_Name.screen_name().toUpperCase();
  if (_.isArray(o)) {
    _.each(o.slice().reverse(), function (m) {

  log(m)
      if (m.author_screen_name.toUpperCase() === sn)
        me_mb_msg(m);
      else
        mb_msg(m);
    });
    return false;
  }

  $('#Message_Board').find('div.msgs').prepend( Template.compile('div.msg', o) );
}

