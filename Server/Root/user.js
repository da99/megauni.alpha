"use strict";
/* jshint esnext: true, undef: true, unused: true */
/* global require, module  */

var app    = require('koa')();
var router = require('koa-router')();


router.post('/user', function *(next) {
  yield next;
  this.set('Content-Type', 'application/json');
  this.body = JSON.stringify({
    error: {username: "Already taken."}
  });
});


app.use(router.routes());
app.use(router.allowedMethods());

module.exports = app;

