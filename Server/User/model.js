"use strict";
/* jshint esnext: true, undef: true, unused: true */
/* global require, module  */

var SQL = require('named_sql');

var User = function (data) {
  this.errors = [];

  if (_.has(data, 'id'))
    this.data = data;
  else
    this.new_data = data;
};

User.cleaners = [];
User.cleaners.push(
  function () {
    if (!this.is_new())
      return;
  }
);

User.prototype.clean = function () {
  var o = this;
  _.detect(User.cleaners, function (f) {
    f();

    return !o.is_valid();
  });

  return this;
}; // === func

User.prototype.is_valid = function () {
  return _.isEmpty(this.errors);
}; // === func

User.prototype.is_new = function () {
  return _.has(this.data, 'id');
}; // === func

User.prototype.save = function *(app) {
  if (this.is_new())
    yield this._save_new(app);
  else
    yield this._save_update(app);

  return this;
}; // === func

User.prototype._save_new = function *(app) {
  yield app.pg.db.query_(SQL());

  return this;
}; // === func

module.exports = User;

