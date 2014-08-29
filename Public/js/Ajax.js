
// ==========================================================
// Example:
//
//   get(url, function ([err], result) {});
//
// ==========================================================
function get(url, func) {
  return promise.get(url).then(json_then(func));
}

// ==========================================================
// Example:
//
//   post(url, [data], function ([err], result) {});
//
// ==========================================================
function post() {
  var args = _.toArray(arguments);
  var func = args.pop();

  if (args.length === 1) {
    args.push({});
  }

  if (args.length === 2) {
    args.push({
      'X-CSRF-Token': _csrf(),
      'Accept': 'application/json'
      // 'Accept-Charset': 'utf-8'
    });
  }

  var prom = promise.post.apply(promise, args);
  return prom.then(json_then(func));
}


function json_then(func) {
  return function (err, results) {

    if (!err && typeof(results) === 'string')
      results = to_json_result(results);

    if (func.length === 2) {
      func(err, results);
    } else {
      if (err)
        log(err);
      else {
        func(to_json_result(results));
      }
      return;
    }
  };
}




// from: http://stackoverflow.com/questions/3710204/how-to-check-if-a-string-is-a-valid-json-string-in-javascript-without-using-try 
function to_json_result(raw_text) {

  if (_.isObject(raw_text) && _.has(raw_text, 'success'))
    return raw_text;

  var text  = "" + raw_text;
  var fails = {success: false, msg: 'Unknown error occurred. Try again later.'};
  var o     = null;
  if (/^[\],:{}\s]*$/.test(text.replace(/\\["\\\/bfnrtu]/g, '@').
                           replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
                           replace( /(?:^|:|,)(?:\s*\[)+/g , ''))
                                   ) {
                                   try {
                                   o = JSON.parse(text);
                                   } catch(e) {
                                   o = null;
                                   }

                                   }
    if (!o)
      return fails;
    if (!_.isObject(o))
       return fails;
    return o;
  }


