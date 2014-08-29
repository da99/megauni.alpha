
$(function () {
  $("#sidebar div.options input[type='checkbox']").change(function () {
    var box = $(this).closest("div.options");
    box.addClass('loading');
    setTimeout(function () {
      box.removeClass('loading');
    }, 500);
  });

  $("#sidebar button").click(function () {
    var box = $(this).closest("div.options");
    box.addClass('loading');
    setTimeout(function () {
      box.removeClass('loading');
    }, 500);
  });

  $('textarea').focus( function () {
    var txt = $(this).val();
    if (txt === 'Type your question here.' || txt === 'Type your reason here.') {
      $(this).val('');
      $(this).removeClass('blurred');
    };
  });

  $('#control_priv').change(function () {
    var textarea = $('#control_priv_specify');
    if ($(this).val() === 'specify')
      textarea.show();
    else {
      textarea.hide();
      var box = $(this).closest("div.options");
      box.addClass('loading');
      setTimeout(function () {
        box.removeClass('loading');
      }, 500);
    };
  });

  $('#show_form_update_content').click(function (e) {
    e.preventDefault();
    $(this).hide();
    $('#form_update_content').show();
  });

});
