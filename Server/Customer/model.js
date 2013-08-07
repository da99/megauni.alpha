var _         = require('underscore')
, bcrypt      = require('bcrypt')
, Duration    = require('duration')
, Check       = require('da_check').Check
, River       = require('da_river').River
, Topogo      = require('topogo').Topogo
, UID         = require('../App/UID').UID
, warn        = require('../App/base').warn
, log         = require('../App/base').log
, Ok          = require('../Ok/model')
, F           = require('tally_ho').Tally_Ho
;

require('../Screen_Name/model');

// ================================================================
// =============== Settings =======================================
// ================================================================



// ================================================================
// =============== Main Object ====================================
// ================================================================

var Customer = exports.Customer = function () {
};

Customer.new = function () {
  var mem = new Customer();
  mem.is_new         = true;
  mem.data           = {screen_name_rows: {}};
  mem.sanitized_data = {};
  mem.new_data       = {};
  return mem;
};

var TABLE_NAME = Customer.TABLE_NAME = 'Customer';
var TABLE      = Customer.TABLE      = Topogo.new(TABLE_NAME);

// ================================================================
// =============== Helper Methods==================================
// ================================================================

function add_leading_zero(n) {
  if (n < 10)
    n = '0' + n;
  return n;
}

function date(d) {
  var m   = add_leading_zero(d.getUTCMonth() + 1);
  var day = add_leading_zero(d.getUTCDate());
  return d.getUTCFullYear() + '-' + m + '-' + day;
}

function add_s(v) {
  return (v > 1 ? 's' : '');
}

function human_durs(durs) {
  var msg = [];
  var d = durs.day;
  var h = durs.hour;
  var m = durs.minute;
  var v = null;

  if (d === 1 && h === 23 && m > 45) {
    d = 2;
    h = 0;
    m = 0;
  }

  v = d;
  if (v > 0)
    msg.push( v + " day" + add_s(v) );

  v = h;
  if (v > 0)
    msg.push(v + " hr" + add_s(v));

  v = m;
  if (v > 0)
    msg.push(v + " min" + add_s(v));

  return msg.join(', ');
}

Customer.prototype.is_id = function (raw_id) {
  var me = this;
  var id = raw_id.toString();
  var rows = me.data.screen_name_rows;
  if (!rows)
    throw new Error('Screen name rows not found.');
  return _.find(rows, function (r) {
    return r.id.toString() === id;
  });
};

Customer.prototype.is = function (name) {
  return !!this.find_screen_name_row(name);
};

Customer.prototype.canonize_screen_name = function (name) {
  var row = this.find_screen_name_row(name);
  return row.screen_name;
};

Customer.prototype.find_screen_name_row = function (raw_name) {
  if (!raw_name)
    throw new Error('Name must be specified: ' + raw_name);

  var name = (raw_name || '').toUpperCase();
  var rows = this.data.screen_name_rows;

  if (!rows)
    throw new Error('Screen name rows not found.');

  return _.find(rows, function (row) {
    return row.screen_name === name || row.display_name.toUpperCase() === name;
  });
};

Customer.prototype.push_sanitized_data = function (k, val) {
  if (!this.validator.has_errors()) {
    this.sanitized_data[k] = val;
  }
};

// ==========================================================
// NOTE: Screen name rows are used in arrays to keep
//       them in order of date created/id.
//       This is why they are not kept more efficiently
//       with {name: row, name: row}.
// ==========================================================
Customer.prototype.push_screen_name_row = function (r) {
  var me    = this;
  var rows  = me.data.screen_name_rows;
  var names = [];

  if (!r.id && r._key)
    r.id = r._key;

  if (!rows) {
    me.data.screen_name_rows = rows = {};
  }

  r.is_trashed = !!r.trashed_at;

  if (r.is_trashed)
    me.generate_trash_msg(r);

  r.world_read   = r.read_able === 'W';
  r.no_one_read  = r.read_able === 'N';
  r.specify_read = r.read_able === 'S';

  _.each('settings details'.split(' '), function (name, i) {
    if (r.hasOwnProperty(name)) {
      if (!r[name] || (r[name].trim && r[name] === ''))
        r[name] = {};
      else
        r[name] = JSON.parse(r[name]);
    }
  });

  rows[r.id] = r;
  return r;
}

Customer.prototype.screen_name_row = function (name, def) {
  var r = this.find_screen_name_row(name);

  if (r)
    return r;

  if (def)
    return def;

  throw new Error('Id not found for customer, ' + this.data.id + ', and name: ' + name);
};

Customer.prototype.screen_names = function () {
  var me = this;
  var rows = me.data.screen_name_rows;
  return _.pluck(_.values(rows).reverse(), 'screen_name');
};

Customer.prototype.screen_name = function (id) {
  return this.screen_name_row( this.screen_name_menu()[id] ).screen_name;
};

Customer.prototype.screen_name_id = function (name) {
  return this.screen_name_row(name).id;
};

Customer.prototype.screen_name_ids = function (arr) {
  var me = this;

  if (!arguments.length)
    return _.pluck(me.data.screen_name_rows, 'id');

  return _.map(arr, function (v) {
    return me.screen_name_row(v).id;
  });
};

Customer.prototype.screen_name_menu = function () {
  var me = this;
  var menu = {};
  _.each(me.data.screen_name_rows, function (r) {
    menu[r.id] = r.screen_name;
  });
  return menu;
};

// ================================================================
// =================== Validations Helpers ========================
// ================================================================


Customer.prototype.validate = function (prefix, keys, o, j) {
  var me            = this;
  me.sanitized_data = {};
  var k             = null;
  var is_valid      = true;

  if (this.is_new) {

    if (!keys) {
      keys = "pass_phrase confirm_pass_phrase ip screen_name".split(' ');
      prefix = 'new_'
    }
    _.each( keys, function (k, i) {
      if (is_valid) {
        me[prefix + k](me.new_data[k]);
        me.is_valid = is_valid = !valid.has_errors();
      }
    });

  } else {

    if (!keys) {
      keys = [
        'screen_name',
        'email',
        'about',
        'homepage_title',
        'homepage_allow',
        'read_able',
        'read_able_list',
        'at_url',
        'bot_url',
        'at_pass_phrase',
        'bot_pass_phrase'
      ];
      prefix = 'edit_';
    }

    _.each( keys, function (k, i) {

      if (is_valid && me.new_data.hasOwnProperty(k)) {
        me[prefix + k](me.new_data[k]);
        me.is_valid = is_valid = !valid.has_errors();
      };

    });

  };

  if (!is_valid && !valid.has_errors())
    throw new Error('Check key names because none were found in new_data: ' + keys);
  this.errors = valid.get_errors();
};



// ================================================================
// ===================  CRUD ======================================
// ================================================================


// ================================================================
// =================== Create Validations =========================
// ================================================================

var Validate_Create = Check.new('create customer', function (vc) {

  vc.define('pass_phrase', function (validator) {
    validator
    .between(6, 100)
    .at_least_2_words('Pass phrase must be two words or more... with spaces.')
    ;
  });

  vc.define('confirm_pass_phrase', function (vador) {
    vador
    .equals(vador.read_sanitized('pass_phrase'), "Pass phrase is different than pass phrase confirmation.")
    ;
  });

  vc.define('ip', function (v) {
    v
    .not_empty('IP address is required.')
    .length_gte(5, 'Valid ip address is required.')
    ;
  });
});


// ================================================================
// =================== Create =====================================
// ================================================================

Customer.create = function (new_vals, flow) {
  var me      = Customer.new();
  me.new_data = new_vals;

  if (!me.new_data.ip) {
    warn('IP address not provided. Using default: 000.000.000');
    me.new_data.ip = '000.000.000';
  }

  // var ucs  = punycode.ucs2.decode(this.screen_name).join('');
  var seed        = UID.to_float(me.new_data.ip + '' + (new Date).getTime());

  if (!me.is_new)
    return flow.error('Can\'t create an already existing record.');


  River.new(flow)

  .job('validate', 'new customer', function (j) {
    Validate_Create.run(me, j);
  })

  .job('create', 'screen name', function (j) {
    Ok.Model.Screen_Name.create(me, j);
  })

  .job('hash pass phrase', function (j) {
    bcrypt.hash(me.sanitized_data.pass_phrase, 13, function (err, hash) {
      if (err)
        return j.finish('invalid', 'Pass phrase could not be hashed.');
      j.finish(hash)
    });
  })

  .job('create', 'customer record', function (j, hash) {
    Topogo
    .new(Customer.TABLE_NAME)
    .create({
      pass_phrase_hash : hash,
      id : me.sanitized_data.id
    }, j);
  })

  .job(function (c_flow, last) {
    me.is_new              = false;
    me.sanitized_data.seed = seed;

    return c_flow.finish(me);
  })

  .run();

  return me;
};

// ================================================================
// =================== Read =======================================
// ================================================================

Customer.read_by_screen_name = function (opts, flow) {
  if (_.isString(opts))
    opts = {screen_name: opts};

  var c_opts = _.pick(opts, 'screen_name', 'pass_phrase');

  F.run(opts, "read life by screen name", function (f) {
    var last = f.last;
    c_opts.id = last.data.owner_id;
    Customer.read_by_id(c_opts, flow);
  });
};

Customer.read_by_id = function (opts, flow) {

  if (_.isString(opts) || _.isNumber(opts))
    opts = {id: opts};

  var customer_row = null;
  var me          = Customer.new();
  var screen_name = opts.screen_name;
  delete opts.screen_name;

  var p           = null;

  if (opts.hasOwnProperty('pass_phrase')) {
    p = opts.pass_phrase;
    delete opts.pass_phrase;
  }

  F.run(
    opts,
    function (j) { TABLE.read_one(opts, j); },

    function (j, last) {
      if (!last)
        return flow.finish(null);
      return j.finish(last);
    },

    function (j) { // Record log in attempt if password provided.
      customer_row = j.last;
      if (!p)
        return j.finish(j.last);

      var sql = "\
      UPDATE @table                                      \n\
      SET log_in_at = CURRENT_DATE, bad_log_in_count = 0 \n\
      WHERE log_in_at != CURRENT_DATE AND id = @id       \n\
      RETURNING *                                        \n\
      ;";

      TABLE.run_and_return_at_most_1(sql, {id: row.id}, j);
    },

    function (j, last_row) { // check log in count
      var row = last_row || customer_row;
      if (!p)
        return j.finish(row);
      if (row.bad_log_in_count < 4)
        return j.finish(row);
      else
        return j.finish('invalid', 'Too many bad log-ins for today. Try again tomorrow.');
    },

    function (j, row) { // hash pass phrase
      if (!p)
        return j.finish(row);

      bcrypt.compare(p, customer_row.pass_phrase_hash, function (err, result) {
        if (err)
          return j.finish('invalid', 'Unable to process pass phrase.');
        if (result)
          return j.finish(row);

        F.run(
          function (j) {
            Topogo.new(Customer.TABLE_NAME)
            .run(
              "UPDATE @table SET bad_log_in_count = (bad_log_in_count + 1)    \n\
              WHERE id = @id                                        \n\
              RETURNING *;",
              {id: row.id},
              j
            );
          },
          function () {
            return j.finish('invalid', 'Pass phrase is incorrect. Check your CAPS LOCK key.');
          }
        );
      });
    }, // === func

    function (j, row) {
      me.is_new                = false;
      me.customer_id           = row.id;
      me.data.id               = row.id;
      me.data.email            = row.email;
      me.data.trashed_at       = row.trashed_at;
      me.data.log_in_at        = row.log_in_at;
      me.data.bad_log_in_count = row.bad_log_in_count;
      return j.finish(me);
    },

    function (j) { // === read screen name
      Ok.Model.Screen_Name.read_list(me, j);
    },

    function (j, last) {
      flow.finish(last);
    }
  ); // === .row

};


// ================================================================
// =================== Update Validations =========================
// ================================================================


var Validate_Update = Check.new('update customer', function (vc) {

  vc.define('email', function (validator) {
    // Do nothing.
  });

});

Customer.prototype.update = function (new_data, flow) {
  var me      = this;
  me.new_data = new_data;

  River.new(flow)

  .job('validate update', 'customer',  function (j) {
    Validate_Update.run(me, j)
  })

  .job('update', 'customer', function (j) {

    var set = {};
    _.each('email'.split(' '), function (key, i) {
      if (me.sanitized_data.hasOwnProperty(key))
        set[key] = me.sanitized_data[key];
    });

    Topogo.new(TABLE_NAME)
    .update_where_set(me.data.id, set, j)

  })

  .job(function (j, r) {
    me.data = r;
    return j.finish(me);
  })

  .run();

};

// ================================================================
// =================== Trash/Delete ===============================
// ================================================================

Customer.prototype.generate_trash_msg = function (name_or_row) {
  var me = this;

  if (name_or_row.screen_name) {
    var name = name_or_row.screen_name;
    var r    = name_or_row;
  } else {
    var name = name_or_row;
    var r    = me.screen_name_row(name);
  }

  if (!r.trashed_at) {

    r.trash_msg = null;

  } else {
    var durs    = new Duration(new Date(Date.now()), reltime.parse(r.trashed_at, "48 hours"));
    var is_past = durs.days < 1 && durs.hour < 1 && durs.minute < 1;
    r.trash_msg = "Screen name, " + r.screen_name;

    if (is_past) {
      r.trash_msg += ", has been deleted. There is no undo.";
    } else {
      r.trash_msg += ", has been put in trash.";
      r.trash_msg += " You have " + human_durs(durs) + " from now to change your mind before it gets completely deleted.";
    }

  }

  return r.trash_msg;
};

Customer.prototype.trash = function (flow) {
  var me = this;
  River.new()
  .job(function (j) {
    Topogo.new(TABLE_NAME)
    .trash(me.data.id, j);
  })
  .run(function (fin, last) {
    me.data.trashed_at = last.trashed_at;
    flow.finish(me);
  });
};

Customer.delete_trashed = function (flow) {

  var final = {customers: [], screen_names: []};

  River.new(flow)

  .job('delete customers', function (j) {
    Topogo.new(TABLE_NAME)
    .delete_trashed(j)
  })

  .job(function (j, rows) {
    if (!rows.length)
      return j.finish(rows);

    final.customers = rows;

    Ok.Model.Screen_Name.delete_by_owner_ids(_.pluck(rows, 'id'), j);
  })

  .job(function (j, sn_rows) {
    final.screen_names = sn_rows;
    return j.finish(final);
  })

  .run();

};





