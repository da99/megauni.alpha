
function key_exists(data) {
  "use strict";

  var copy_value = Dum_Dum_Boom_Boom.common.base.copy_value;
  var KEY = data.args[0];
  var FUNC = data.args[1];
  var ON_TRUE = copy_value(data);
  var ON_FALSE = copy_value(data);

  ON_TRUE.args = [KEY];
  ON_FALSE.args = ['!' + KEY];

  window[FUNC](ON_TRUE);
  window[FUNC](ON_FALSE);

  return true;
} // === key_exists
