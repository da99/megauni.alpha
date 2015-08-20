"use strict";
/* jshint esnext: true, undef: true, unused: true */
/* global require, module  */

var app    = require('koa')();
var router = require('koa-router')();


router.post('/create-user', function *(next) {
  yield next;
  this.set('Content-Type', 'text/plaintext');
  var result = yield this.pg.db.client.query_('SELECT now()');
  this.body = result.rows[0].now.toISOString() + "| | ---";
});


app.use(router.routes());
app.use(router.allowedMethods());

module.exports = app;

