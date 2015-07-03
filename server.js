
var koa_static = require('koa-static');
var helmet     = require('koa-helmet');
var mount      = require('koa-mount');
var koa        = require('koa');
var port       = process.env.PORT;

var app    = koa();
var homepage = require('./Server/Root/homepage')

// === Set security before routes:
app.use(helmet.defaults());

// === Finally, the routes:
app.use(koa_static('./Public'));

app.use(mount(homepage.routes()));
app.use(mount(homepage.allowedMethods()));

// app.use(mount(members));
// app.use(mount(www_apps));

// === Start the server.
app.listen(port, function() {
  console.log('Listening on: ' + port);
});
