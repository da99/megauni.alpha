
var KOA_GENERIC_SESSION = require('koa-generic-session');
var KOA_PG_SESSION      = require('koa-pg-session');

var koa_static = require('koa-static');
var helmet     = require('koa-helmet');
var mount      = require('koa-mount');
var koa        = require('koa');
var port       = process.env.PORT;

var app    = koa();
var homepage = require('./Server/Root/homepage')

// === Set security before routes:
app.use(helmet.defaults());
app.use(helmet.csp({
  'default-src': ["'self'"]
}));

// === Static files before session:
app.use(koa_static('./Public'));

app.keys = [process.env.SESSION_SECRET, process.env.SESSION_SECRET + Math.random().toString()];

app.use(KOA_GENERIC_SESSION({
  store: new KOA_PG_SESSION(process.env.DATABASE_URL),
  {
    path: "/",
    secureProxy: !!process.env.IS_DEV
  }
}));


// === Finally, the routes:
app.use(mount(homepage));
// app.use(mount(members));
// app.use(mount(www_apps));

// === Start the server.
app.listen(port, function() {
  console.log('Listening on: ' + port);
});
