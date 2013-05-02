var _         = require('underscore')
, Customer    = require('../Server/Customer/model').Customer
, Screen_Name = require('../Server/Screen_Name/model').Screen_Name
, River       = require('da_river').River
, Topogo      = require('topogo').Topogo
;


function close() {
  Topogo.close();
};

process.on('SIGTERM', close);
process.on('SIGINT',  close);
process.on('exit',    close);

exports.open_screen_names = function (j) {
  var sql = "UPDATE " + Screen_Name.TABLE_NAME + " SET read_able = ARRAY[ '@W' ] RETURNING id ; ";
  var vals = [];
  Topogo.run( Topogo.new(Screen_Name.TABLE_NAME), sql, vals, j);
};

exports.throw_it = function () {
  throw new Error(arguments[0].toString());
  return false;
}

exports.utc_timestamp = function () {
  var d = new Date;
 return (d.getTime() + d.getTimezoneOffset()*60*1000);
}

exports.utc_diff = function (date) {
  if (date && date.getTime)
    date = date.getTime();
  return exports.utc_timestamp() - date;
}
exports.is_recent = function (date) {
  return ((new Date).getTime() - date.getTime()) < 80;
}

exports.ago = function (english) {
  switch (english) {
    case '-1d -22h':
      return (new Date( (new Date).getTime() - (1000 * 60 * 60 * 24) - (1000 * 60 * 60 *22) ));
      break;
    case '-3d':
      return (new Date( (new Date).getTime() - (1000 * 60 * 60 * 24 * 3) ));
      break;
    default:
      throw new Error('Unknown: ' + english);
  };
};

Topogo.prototype.drop = function (flow) {
  var me = this;
  return Topogo.run(me, "DROP TABLE \"" + me.table + '"; ', [], flow);
};

Topogo.prototype.delete_all = function (flow) {
  var sql = 'DELETE FROM \"' + this.table + '\" ;';
  return Topogo.run(this, sql, [], flow);
};

Customer.delete_all = function (flow) {

  River.new(flow)
  .job('delete customers', function (j) {
    Topogo.new(Customer.TABLE_NAME).delete_all(j);
  })
  .job('delete screen_names', function (j) {
    Topogo.new(Screen_Name.TABLE_NAME).delete_all(j);
  })
  .run();

}; // end .delete_all

Customer.create_sample = function (sn, flow) {

  var o = {
    screen_name         : sn,
    pass_phrase         : "this is a pass",
    confirm_pass_phrase : "this is a pass",
    ip                  : '000.00.000'
  };

  River.new(flow)
  .job('create customer', [Customer, 'create', o])
  .run();

}; // end .create_sample

