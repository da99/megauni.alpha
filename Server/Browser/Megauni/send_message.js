
function send_message(data) {
  var KEY       = data.args[0];
  var CLEAN_KEY = _.trimStart(KEY, '!');
  var msg       = {};

  if (CLEAN_KEY !== KEY) // "KEY" !== "!KEY"
    msg[CLEAN_KEY] = false;
  else
    msg[CLEAN_KEY] = true;

  App("send message", msg);
} // send_message
