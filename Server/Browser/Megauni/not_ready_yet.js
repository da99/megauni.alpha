

function not_ready_yet(name) {
  "use strict";

  log(name);
  function _not_ready_yet_(data) {
    log("Not ready: " +  name);
    return data;
  }

  return _not_ready_yet_;
}

