

function hide(data) {
  "use strict";
  if (Dum_Dum_Boom_Boom.common.base.is_empty(data.args)) {
    $('#' + data.dom_id).hide();
    return;
  }

  return Dum_Dum_Boom_Boom.browser.dom.hide(data);
} // === mu_hide
