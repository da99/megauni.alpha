
var app    = require('koa')();
var router = require('koa-router')();
var koa_pg = require('koa-pg')


var fs                = require('fs');
var homepage_stranger = fs.readFileSync(process.cwd() + '/Public/applets/homepage_stranger/markup.html');


router.get('/', function *homepage(next) {
  yield next;
  this.set('Content-Type', 'text/html');
  this.body = homepage_stranger;
});

router.get('/time', function *homepage_time(next) {
  yield next;
  this.set('Content-Type', 'text/plaintext');
  var result = yield this.pg.db.client.query_('SELECT now()');
  this.body = result.rows[0].now.toISOString() + "| | ---";
});

router.get('/script', function *count() {
  this.type = 'html';
  this.body = "<html><head><script src='http://script.com/'></script></head><body>Script</body></html>";
});

router.get('/count', function *count() {
  var session = this.session;
  session.count = session.count || 0;
  session.count++;
  this.type = 'text';
  this.body = session.count.toString();
});


app.use(koa_pg(process.env.DATABASE_URL));
app.use(router.routes());
app.use(router.allowedMethods());

module.exports = app;

