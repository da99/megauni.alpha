
var _         = require("underscore")._

, Screen_Name = require("../Screen_Name/model").Screen_Name
, Ok          = require('../Ok/model')
, log         = require("../App/base").log

, Topogo      = require("topogo").Topogo
, River       = require("da_river").River
, Check       = require('da_check').Check
;


var MODEL = exports.MODEL = Ok.Model.new(function () {});

var TABLE_NAME = exports.MODEL.TABLE_NAME = "MODEL";
var TABLE = Topogo.new(TABLE_NAME);

MODEL._new = function () {
  var o = this;
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

  River.new(flow)
  .job(function (j) {
    TABLE.create(data, j);
  })
  .job(function (j, record) {
    j.finish(MODEL.new(record));
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






