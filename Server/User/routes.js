"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global require, module, process  */

var log;
log = function () {
  return (process.env.IS_DEV) ? console.log.apply(console, arguments) : null;
};

var app    = require('koa')();
var router = require('koa-router')();
var _      = require('lodash');
var User   = require('../User/model');

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

router.post('/user', function *(next) {
  this.set('Content-Type', 'application/json');

  // log(this.request.body);
  // this.body = JSON.stringify(invalid_data({screen_name: 'Already taken.'}));
  // yield next;
  // return;

  var msg;

  // === Save data to DB:
  var new_user = new User(this.request.body);
  yield new_user.save(this);

  // if error:
  if (new_user.has_errors())
    msg = invalid_data(new_user.errors);
  else {
    this.regenerateSession();
    // log_in_user();
    msg = success_msg('User created.', {screen_name: new_user.screen_name});
  }


  this.body = JSON.stringify(msg);
  yield next;
});

app.use(router.routes());
app.use(router.allowedMethods());

module.exports = app;

