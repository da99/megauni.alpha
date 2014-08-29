
$(function() {
  // ================================================================
  // ================== Follow ======================================
  // ================================================================
  if (!Customer.is_owner_of_screen_name) {
    form('#Create_Follow', function (f) {
      f.on_success(function (result) {
        log(result);
        $('#Follow').addClass('is_following');
      });
    });

    form('#Delete_Follow', function (f) {
      f.on_success(function (result) {
        log(result);
        var msg = f.find('div.success').text();
        make_form_like_new(f);
        $('#Follow').removeClass('is_following');
        $('#Create_Follow div.success').text(msg);
      });
    });
  }

}); // ==== dom ready
