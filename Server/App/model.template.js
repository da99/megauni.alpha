
var _    = require("underscore")
, 123    = require("../123/model").123
, Topogo = require("topogo").Topogo
, River  = require("da_river").River
;


var MODEL = exports.MODEL = function () {};
var TABLE_NAME = exports.MODEL.TABLE_NAME = "MODEL";
var TABLE = Topogo.new(TABLE_NAME);

MODEL.new = function (data) {
  var o = new MODEL();
  o.data = data;
  return o;
};

function null_if_empty(str) {
  if (!str) return null;
  str = str.trim();
  if (!str.length)
    return null;
  return str;
}

// ================================================================
// ================== Create ======================================
// ================================================================
MODEL.create = function (raw_data, flow) {
  var data = {
  };

  var sql = "";

  River.new(flow)
  .job(function (j) {
    TABLE.run(sql, data, j);
  })
  .job(function (j, rows) {
    j.finish(MODEL.new(rows[0]));
  })
  .run();
};

// ================================================================
// ================== Read ========================================
// ================================================================


// ================================================================
// ================== Update ======================================
// ================================================================

// ================================================================
// ================== Trash/Untrash ===============================
// ================================================================

// ================================================================
// ================== Delete ======================================
// ================================================================






