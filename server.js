
var KOA_GENERIC_SESSION = require('koa-generic-session');
var KOA_PG_SESSION      = require('koa-pg-session');

var koa_static = require('koa-static');
var helmet     = require('koa-helmet');
var mount      = require('koa-mount');
var koa        = require('koa');
var port       = process.env.PORT;
var logger     = require('koa-logger');

var app    = koa();
var homepage = require('./Server/Root/homepage')

if (process.env.IS_DEV) {
  app.use(logger());
}

// === Set security before routes:
app.use(helmet.defaults());
app.use(helmet.csp({
  'default-src': ["'self'"]
}));

if (!process.env.IS_DEV) {
  app.use(helmet.hsts(31536000, true, true));
}

// === Static files before session:
app.use(koa_static('../megauni.js/Public'));

app.keys = [process.env.SESSION_SECRET, process.env.SESSION_SECRET + Math.random().toString()];

app.use(KOA_GENERIC_SESSION({
  store: new KOA_PG_SESSION(process.env.DATABASE_URL),
  cookie: {
    path: "/",
    secureProxy: !process.env.IS_DEV
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
