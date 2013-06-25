
"use strict";
$(function () {

  // ================================================================
  // ================== Helpers =====================================
  // ================================================================

  // ================================================================
  // ================== EVENTS ======================================
  // ================================================================

  // ================================================================
  // ================== FORMs =======================================
  // ================================================================
  form('#create_account', function (f) {
    f.on_success(function (result) {
      reset_form_to_submit_more(f);
      f.find('div.success').append($('<a href="L">L</a>'.replace(/L/g, result.location)));
      erase_url_wanted();
      document.location.href = result.location;
    });
  });

}); // $(function) ======================================
