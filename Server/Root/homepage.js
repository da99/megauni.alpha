
var fs          = require('fs');
var koa         = require('koa');
var app         = koa();
var router      = require('koa-router')();
var homepage_stranger = fs.readFileSync(process.cwd() + '/Public/applets/homepage_stranger/markup.html');

var koaPg = require('koa-pg')

router.get('/', function *homepage(next) {
  yield next;
  this.set('Content-Type', 'text/html');
  this.body = homepage_stranger;
});

router.get('/time', function *homepage_time(next) {
  yield next;
  this.set('Content-Type', 'text/plaintext');
  var result = yield this.pg.db.client.query_('SELECT now()');
  this.body = result.rows[0].now.toISOString();
});

app.use(koaPg(process.env.DATABASE_URL));
app.use(router.routes());
app.use(router.allowedMethods());

module.exports = app;

