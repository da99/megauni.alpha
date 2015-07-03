
var fs          = require('fs');
var koa         = require('koa');
var app         = koa();
var router      = require('koa-router')();
var html        = fs.readFileSync(process.cwd() + '/Public/applets/homepage_stranger/markup.html');


router.get('/', function *homepage(next) {
  yield next;
  this.set('Content-Type', 'text/html');
  this.body = html;
});


module.exports = router;
