
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

var Bot = Ok.Model.new(exports, 'Bot');

var TABLE_NAME = Bot.TABLE_NAME = "Bot";
var TABLE = Topogo.new(TABLE_NAME);

Bot._new = function () {
  var o = this;
  return o;
};


// ================================================================
// ================== Helpers =====================================
// ================================================================

function extract_name(o) {
  if (o.screen_name)
    return H.canonize_screen_name(o.screen_name).split('@');
  return [o.sub_sn, o.owner];
}

Bot.prototype.to_client_side = function () {
  var me = this;
  return {
    screen_name: me.data.screen_name
  };
};


// ================================================================
// ================== Create ======================================
// ================================================================

F.on('create Bot', function (flow) {
  flow.detour(

    'create Screen_Name_Sub', {type: 'bot'},

    function (f) {
      f.data.Screen_Name_Sub = f.last;
      TABLE.create({screen_name_sub_id: f.last.data.id}, f);
    },

    function (f) {
      var data = _.extend(
        {},
        f.data.Screen_Name_Sub,
        f.last
      );

      f.finish(Bot.to_public_data(data));
    }

  );
});


// ================================================================
// ================== Read ========================================
// ================================================================

F.on('read Multi-Life Page', function (flow) {
  if (!f.data.Bots)
    return f.finish();
  flow.detour(
    'read Bot list for owner',
    function (f2) {
      f.data.Bots.Own = Bot.to_client_side(f2.last);
      f2.finish();
    }
  );
});

F.on('read Bot list for owner', function (flow) {
  flow.run(

    function (f2) {
      var sql = "\
      SELECT owner_id, sub_sn                     \n\
      FROM @Screen_Name_Sub                       \n\
      WHERE type_id = @bot_type                   \n\
            AND owner_id IN @sn_ids               \n\
      ;";
      TABLE.run(sql, {
        sn_ids   : flow.data.user.screen_name_ids(),
        bot_type : Ok.Model.Screen_Name_Sub.to_type_id('bot')
      }, f2);
    },

    "add screen names using user",

    function (f2) {
      f2.finish(Bot.to_client_side(f2.last));
    }

  );
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
      return Bot.to_client_side(r);
    }));
  })
  .run();
};

F.on('read Bot by screen name', function (flow) {

  flow.detour(

    function (j) {
      var pieces = j.data.screen_name.split('@');
      var data = {
        sub_sn: pieces[0],
        owner: pieces[1]
      };

      var sql = Ok.SQL("\
        SELECT CONCAT(sub_sn, '@', @Screen_Name.screen_name) AS screen_name      \n\
        FROM @Screen_Name_Sub INNER JOIN @Screen_Name                   \n\
              ON @Screen_Name_Sub.owner_id = @Screen_Name.id            \n\
        WHERE screen_name = @owner AND       \n\
              sub_sn = @sub_sn               \n\
        LIMIT 1                              \n\
      ;");

      TABLE.run_and_return_at_most_1(sql, data, j);
    },

    function (j) {
      j.finish(Bot.new(j.last));
    }

  );

});


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






