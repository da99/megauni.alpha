var _ = require('underscore')
;

var Validate = exports.Validate = function (name, init) {
  this.name        = name;
  this.trim_all    = true;
  this.is_valid    = true;
  this.validations = {};
  if (init)
    init(this);
};

var V = Validate;

V.new = function (name, init) {
  var v = new V(name, init);
  return v;
};

V.prototype.define = function(name, func) {
  var me = this;
  if (me.validations[name])
    throw new Error(name + ' already defined.');

  if (_.isFunction(func))
    me.validations[name] = func;
  else {
    func = func.validations[name];
    if (!func)
      throw new Error('"' + name + '" not defined in previous validation.');
    me.validations[name] = func;
  }

  return me;
};

V.prototype.validate = function (target, flow) {
  var me = this;
  if (!target.sanitized_data)
    target.sanitized_data = {};

  var last_v = null;

  _.find(me.validations, function (func, k) {
    if (!target.new_data.hasOwnProperty(k))
      return false;

    var v = Validation.new(me, k, target);
    func(v);

    last_v = v;
    return !v.is_valid;
  });

  if (!last_v)
    last_v = {is_valid: true};

  if (flow) {
    if (last_v.is_valid && flow.finish)
      flow.finish();
    else if (!last_v.is_valid && flow.invalid)
      flow.invalid(last_v.error_msg, last_v);
  }

  return last_v.is_valid;
};


var Validation = function (validate, key, target) {
  var me         = this;
  me.validate    = validate;
  me.key         = key;
  me.english_key = key.replace(/_/g, ' ');
  me.target      = target;
  me.val         = target.new_data[key];
  me.is_valid    = true;

  if (me.validate.trim_all && me.val && me.val.trim)
    me.sanitized(me.val.trim());
};

Validation.new = function (v, k, t) {
  var v = new Validation(v, k, t);
  return v;
};

Validation.prototype.sanitized = function (v) {
  var me = this;

  if (arguments.length === 2) {
    me.target.sanitized_data[arguments[0]] = arguments[1];
    return arguments[1];
  }

  me.val = me.target.sanitized_data[me.key] = v;
  return me.val;
};

Validation.define = function (name, func) {
  Validation.prototype[name] = function () {
    var me = this;
    if (!me.validate.is_valid)
      return me;

    var args = _.toArray(arguments);
    var result = func.apply(me, args);

    if (result[0]) {
      me.sanitized(result[1]);
      return me;
    }

    me.is_valid  = false;
    me.error_msg = me.target.errors = result[1];

    return me;
  };
};

Validation.define('at_least', function (n, msg) {
  var me = this;

  if (me.val &&
      me.val.length &&
        me.val.length >= n)
    return [true, me.val];

  msg = msg || me.english_key + (' must be at least: ' + n);
  return [false, msg];
});

Validation.define('at_most', function (n, msg) {
  var me = this;

  if (me.val &&
      me.val.length &&
        me.val.length <= n)
    return [true, me.val];

  msg = msg || me.english_key + (' can not be more than: ' + n);
  return [false, msg];
});

Validation.define('between', function (min, max, msg) {
  var me = this;
  msg = msg || me.english_key + ' must be between: ' + min + ' and ' + max;

  me
  .at_least(min, msg)
  .at_most(max, msg);

  if(me.is_valid)
    return [true, me.val];
  return [false, msg];

});


Validation.define('at_least_2_words', function (msg) {
  var me = this;
  var v = (me.val || '').trim();

  if(v.indexOf(' ') > 0)
    return [true, v];

  msg = msg || me.english_key + ' must be two words or more.';
  return [false, msg];

});

Validation.define('equals', function (v, msg) {
  var me = this;
  msg = msg || me.english_key + ' must equal: ' + v;
  if (v !== me.val)
    return [false, msg];
  return [true, v];
});

Validation.define('to_upper_case', function (msg) {
  var me = this;
  me.not_empty();
  if (me.is_valid)
    return [true, this.val.toUpperCase()];
  else
    return [false, (msg || 'Can\'t be empty: ' + this.english_key)];
});

Validation.define('is_null_if_empty', function (msg) {
  var v = this.val;
  if (!v || (v.trim && v.trim() === ''))
    return [true, null];
  return [true, v];
});

Validation.define('not_empty', function (msg) {
  var me = this;
  msg = msg || me.english_key + ' must not be empty.';
  if (_.isArray(me.val)) {
    var v = _.compact(me.val);
  } else {
    var v = (me.val || '').trim();
  };

  if (v.length > 0)
    return [true, v];
  return [false, msg];
});

Validation.define('length_gte', function (min, msg) {
  var me = this
  , val  = me.val || '';

  msg = msg || 'Length of ' + me.english_key + ' must be greater or equal to: ' + min;

  if (val.trim)
    val = val.trim();

  if (_.isArray(val))
    val = _.compact(val);

  if (val.length >= min)
    return [true, val];

  return [false, msg];
});

Validation.define('match', function (regex, msg) {
  var me = this;
  msg = msg || me.english_key + ' must match: ' + regex;
  if (me.val && !me.val.match)
    return [false, me.english_key + ' is not a string: '];
  if ((me.val || '').match(regex))
    return [true, me.val];
  return [false, msg];
});

Validation.define('not_match', function (regex, msg) {

  var me = this;
  msg = msg || me.english_key + ' must not match: ' + regex;
  if (me.val && !me.val.match)
    return [false, me.english_key + ' is not a string.'];
  if ((me.val || '').match(regex))
    return [false, msg];
  return [true, me.val];
});

Validation.define('found_in', function (arr, msg) {
  var me = this;
  msg = msg || me.english_key + ' must be one of the following: ' + arr.join(', ');
  if (_.contains(arr, me.val))
    return [true, me.val];
  return [false, msg];
});

Validation.define('contains_only', function (arr, msg) {
  var me = this;
  msg = msg || me.english_key + ' must only contain the following: ' + arr.join(', ');
  var has_invalid = false;
  _.each(me.val, function (v) {
    if (!_.contains(arr, v))
      has_invalid = true;
  });

  if (!has_invalid)
    return [true, me.val];

  return [false, msg];

});





