"use strict";
/* jshint esnext: true, undef: true, unused: true */
/* global require, module  */

var app    = require('koa')();
var router = require('koa-router')();


// var fs                = require('fs');
// var homepage_stranger = fs.readFileSync(process.cwd() + '/Public/applets/homepage/markup.html');


// router.get('/', function *homepage(next) {
  // yield next;
  // this.set('Content-Type', 'text/html');
  // this.body = homepage_stranger;
// });

router.get('/time', function *homepage_time(next) {
  this.set('Content-Type', 'text/plaintext');

  var result = yield this.pg.db.client.query_('SELECT now()');
  this.body = result.rows[0].now.toISOString() + "| | ---";
  yield next;
});

router.get('/script', function *count(next) {
  this.type = 'html';
  this.body = "<html><head><script src='http://script.com/'></script></head><body>Script</body></html>";

  if (next) yield next;
});

router.get('/count', function *count(next) {
  var session = this.session;
  session.count = session.count || 0;
  session.count++;
  this.type = 'text';
  this.body = session.count.toString();

  if (next) yield next;
});


app.use(router.routes());
app.use(router.allowedMethods());

module.exports = app;

