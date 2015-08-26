"use strict";
/* jshint esnext: true, undef: true, unused: true */
/* global require, module, process  */

var log;
log = function () {
  return (process.env.IS_DEV) ? console.log.apply(console, arguments) : null;
};

var app    = require('koa')();
var router = require('koa-router')();

router.get('/_csrf', function* (next) {
  this.set('Content-Type', 'application/json');
  this.body = JSON.stringify({_csrf: this.csrf + '__'});
  yield next;
});

app.use(router.routes());
app.use(router.allowedMethods());

module.exports = app;
