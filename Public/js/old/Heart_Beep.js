

var Heart_Beep = function () {
  this.default_wait = 4000;
  this.timeout(null);
};

Heart_Beep.new = function () {
  return (new Heart_Beep);
};

Heart_Beep.prototype.timeout = function (v) {
  if (arguments.length === 0)
    return this.timeout_val;
  this.timeout_val = v;
};

Heart_Beep.prototype.start = function () {
  var me = this;
  me.wait_and_read(400);
};

Heart_Beep.prototype.wait_and_read = function (ms) {
  var me = this;
  me.timeout(setTimeout(function () {
    me.timeout(null);

    if (is_dev) {
      if (!me.read_count)
        me.read_count = 0;
      me.read_count += 1;
      if (false && me.read_count > 30) {
        log('Stopping: Heart_Beep # wait_and_read because of dev env.');
        return null;
      }
    }

    me.read();
  }, (ms || me.default_wait)));
}

Heart_Beep.prototype.read = function () {
  var me = this;

  var o = {
    type        : 'POST',
    url         : Box.base_url + "/chat/heart-beep",
    cache       : false,
    contentType : 'application/json',
    data        : JSON.stringify({"_csrf": csrf_token_val() }),
    dataType    : 'json',
    success     : function (resp, stat) {
      log(resp, stat);
      me.wait_and_read();
    },
    error       : function (xhr, textStatus, errThrown) {
      log(textStatus, errThrown || "Either the website is down or your Internet connect is down.");
      me.wait_and_read();
    }
  };

  $.ajax(o);
};
