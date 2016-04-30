
// ========= OLD CODE =================
//
  // form('#Create_Folder form', function (f) {
    // f.on_success(function (result) {
      // log(result);
      // var new_folder = Template.compile('div.folder', {'TITLE': result.name, 'LOCATION': result.location});
      // $('div.boxs').prepend(new_folder);
    // });

    // var path          = window.location.pathname;
    // var parent        = $(this).parent();
    // var orig_text     = $(this).text();
    // var link          = $(this);
    // var id            = 'create_folder_loading' ;
    // var ele           = $('<div class="loading ' + id + '">Processing...</div>');

    // $(this).after(ele);
    // $(this).hide();

    // post((path + '/create/folder').replace('//', '/'), function (err, results) {
      // ele.remove();

      // if (err) {

        // log(err, results);

        // var err_id = 'create_folder_error';
        // var min_15  = (1000 * 60 * 15);
        // link.after($('<div class="errors ' + err_id + '">Error occurred. Try again in...</div>'));
        // every_sec($(parent).find('div.' + err_id), function (target, since) {
          // if (since > min_15) {
            // link.show();
            // target.remove();
            // return;
          // }
          // target.text('Error occurred. Try again in ' + min_sec(min_15 - since) + ' mins.');
          // return true;
        // });

        // return;
      // }

      // link.show();
      // var succ = $('<div class="success">Your new folder is at: <a href="HREF">HREF</a></div>'.replace(/HREF/g, results.location));
      // link.after(succ);

    // });

    // log(orig_text);
  // });

