function folder(f) {
  var parent = $('#Folders ul.folders');
  parent.prepend(Template.compile('li.folder', f));
  parent.show();
}


$(function() {
  // ============================================
  // ================ Create Folder..............
  // ============================================
  form('#Create_Folder', function (f) {
    f.at_least_one_not_empty('input[type="text"]');
    f.on_success(function (result) {
      result.location = Screen_Name.to_url('/folder/' + result.num);
      f.find('div.success').html("New folder is at: <a href=\"LOC\">LOC</a>".replace(/LOC/g, result.location));
      log(result)
      folder(result);
    });
  });

}); // ==== dom ready
