
var _         = require("underscore")._

, Ok          = require('../Ok/model')
, log         = require("../App/base").log
, H           = require("../App/Helpers").H

, Topogo      = require("topogo").Topogo
, River       = require("da_river").River
, Check       = require('da_check').Check
, E_E_E       = require('escape_escape_escape').Sanitize.html
, UN_ESCAPE   = require('escape_escape_escape').Sanitize.un_escape
, F           = require('tally_ho').Tally_Ho
;

require('./Code');

var Bot = exports.Bot = Ok.Model.new(function () {});

var TABLE_NAME = exports.Bot.TABLE_NAME = "Bot";
var TABLE = Topogo.new(TABLE_NAME);

Bot._new = function () {
  var o = this;
  return o;
};

Bot.prototype.public_data = function () {
  var me = this;
  return {
    sub_sn      : me.data.sub_sn,
    owner       : me.data.owner,
    screen_name : me.data.sub_sn + '@' + me.data.owner,
    code        : me.data.code,
    o_code      : me.data.code && E_E_E(JSON.parse(UN_ESCAPE(me.data.code)))
  };
};

// ================================================================
// ================== Helpers =====================================
// ================================================================

function extract_name(o) {
  if (o.screen_name)
    return H.canonize_screen_name(o.screen_name).split('@');
  return [o.sub_sn, o.owner];
}

Bot.prototype.public_data = function () {
  var me = this;
  return {
    screen_name: me.data.screen_name
  };
};


// ================================================================
// ================== Create ======================================
// ================================================================
Bot.create = function (raw_data, flow) {
  var sub_sn = H.null_if_empty(raw_data.sub_sn.toLowerCase().replace(Screen_Name.INVALID_CHARS, '').slice(0,15));
  var owner  = H.null_if_empty(raw_data.owner);
  var sn     = sub_sn + '@' + owner;
  var sn_sub = null;
  var data = {
    type_id     : 0,
    sub_sn      : sub_sn,
    owner       : owner
  };

  River.new(flow)
  .job(function (j) {
    Topogo.new("Screen_Name_Sub")
    .on_dup(function (constraint_name) {
      j.finish('invalid', "Name already taken: " + sn);
    })
    .create(data, j);
  })
  .job(function (j, last) {
    sn_sub = last;
    TABLE
    .create({screen_name_sub_id: last.id}, j);
  })
  .job(function (j, record) {
    j.finish(Bot.new(_.extend({}, sn_sub, record)));
  })
  .run();
};

// ================================================================
// ================== Read ========================================
// ================================================================

F.on('read Multi-Life Page', function (f) {
  if (!f.data.Bots)
    f.finish();
  F.run(function (f2) {
    var sql = "\
      SELECT sub_sn,                              \n\
        screen_name AS owner_screen_name,         \n\
        CONCAT(sub_sn, '@', owner_screen_name)    \n\
        AS screen_name                            \n\
      FROM @SUBS INNER JOIN @SNAMES               \n\
        ON  @SUBS.owner_id = @SNAMES.id           \n\
      WHERE type_id = @bot_type                   \n\
    ;";
    TABLE.run(sql, {
      TABLES: {SN_SUBS: Ok.Screen_Name.TABLE_NAME},
      sn_ids: f2.data.customer.screen_name_ids(),
      bot_type: Ok.Screen_Name.sub_type_map['bot']
    }, f2);
  }, function (f2) {
    f.finish(Bot.public_data(f2.last));
  });
});

Bot.read_list_to_run = function (sn, flow) {
  River.new(flow)
  .job('read', function (j) {
    TABLE.run("\
              SELECT *                              \n\
              FROM @table RIGHT JOIN @SNS           \n\
                   ON @table.screen_name_sub_id =   \n\
                      @SNS.id                       \n\
              WHERE @SNS.id in (                    \n\
                SELECT bot_id                       \n\
                FROM @BU                            \n\
                WHERE owner = @sn                   \n\
              ) AND code IS NOT NULL                \n\
              ;", {sn: sn, TABLES: {
                SNS: "Screen_Name_Sub",
                BU: "Bot_Use"
              }}, j);
  })
  .job('to objects', function (j, list) {
    j.finish(_.map(list, function (r) {
      return Bot.new(r).public_data();
    }));
  })
  .run();
};

F.on('read Bot by screen name', function (flow) {

  F.run(flow, function (j) {
    var pieces = flow.data.screen_name.split('@');
    var data = {sub_sn: pieces[0], owner: pieces[1]};
    var sql = "\
      SELECT *                       \n\
      FROM @table RIGHT JOIN         \n\
        \"Screen_Name_Sub\"          \n\
        ON @table.screen_name_sub_id = \
           \"Screen_Name_Sub\".id    \n\
      WHERE sub_sn = @sub_sn AND     \n\
            owner  = @owner          \n\
      LIMIT 1                        \n\
    ;";

    TABLE.run_and_return_at_most_1(sql, data, j);
  }, function (j) {
    j.finish(Bot.new(j.last));
  });

});

Bot.read_by_screen_name = function (sn, flow) {
  var pieces = sn.split('@');
  River.new(flow)
  .job('read', function (j) {
    TABLE.read_one({sub_sn: pieces[0], owner: pieces[1]}, j);
  })
  .job('to object', function (j, last) {
    j.finish(Bot.new(last));
  })
  .run();
};

// ================================================================
// ================== Update ======================================
// ================================================================
Bot.update = function (data, flow) {
  var clean = _.pick(data, 'code', 'about_me');
  var sn    = extract_name(data);

  if (clean.about_me)
    clean.about_me = H.null_if_empty(clean.about_me);

  if (clean.code) {
    clean.code = UN_ESCAPE(clean.code);
    if (!H.is_json(clean.code)) {
      return flow.finish('invalid', 'Code is invalid JSON.');
    }
    clean.code = JSON.stringify(E_E_E(JSON.parse(clean.code)));
  }

  River.new(flow)
  .job('read sn', function (j) {
    Topogo.new("Screen_Name_Sub")
    .read_one({
      sub_sn: sn[0],
      owner: sn[1]
    }, j);
  })
  .job('update bot', function (j, last) {
    if (!last)
      return j.finish("invalid", "Bot not found: " + sn.join('@'));
    TABLE.update_one({screen_name_sub_id: last.id}, clean, j);
  })
  .job('to object', function (j, row) {
    j.finish(Bot.new(row));
  })
  .run();
};

// ================================================================
// ================== Trash/Untrash ===============================
// ================================================================

// ================================================================
// ================== Delete ======================================
// ================================================================






