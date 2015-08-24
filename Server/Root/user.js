"use strict";
/* jshint esnext: true, undef: true, unused: true */
/* global require, module  */

var app    = require('koa')();
var router = require('koa-router')();
var _      = require('lodash');

function invalid_data(fields) {
  return {
    error: {
      tags : ['invalid data'],
      fields: fields
    }
  } ;
}

function success_msg(msg, data) {
  return {success: _.extend({msg: msg}, data || {})};
}

var User = function (data) {
};

User.prototype.is_new = function () {
  return _.isNumber(this.data.id) && !_.isNaN(this.data.id);
}; // === func

User.prototype.save = function () {
  if (this.is_new())
    this._save_new();
  else
    this._save_update();
}; // === func

User.prototype._save_new = function () {
  
}; // === func

router.post('/user', function *(next) {

  var msg;

  // === Save data to DB:
  var new_user = new User(DATA);
  yield new_user.save();

  // if error:
  if (new_user.has_errors())
    msg = invalid_data(new_user.errors);
  else {
    this.regenerateSession();
    log_in_user();
    msg = success_msg('User created.', {screen_name: new_user.screen_name});
  }


  this.set('Content-Type', 'application/json');
  this.body = JSON.stringify(msg);
  yield next;
});


app.use(router.routes());
app.use(router.allowedMethods());

module.exports = app;

