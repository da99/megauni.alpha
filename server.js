"use strict";
/* jshint esnext: true, undef: true, unused: true */
/* global process, require  */


var KOA_GENERIC_SESSION = require('koa-generic-session');
var KOA_PG_SESSION      = require('koa-pg-session');

var koa        = require('koa');
var koa_static = require('koa-static');
var helmet     = require('koa-helmet');
var mount      = require('koa-mount');
var logger     = require('koa-logger');
var koa_pg     = require('koa-pg');

var port     = process.env.PORT;
var app      = koa();
var homepage = require('./Server/Root/homepage');
var user     = require('./Server/Root/user');

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
if (process.env.IS_DEV) {
  app.use(koa_static('../megauni.html/Public'));
}

app.keys = [process.env.SESSION_SECRET, process.env.SESSION_SECRET + Math.random().toString()];

app.use(KOA_GENERIC_SESSION({
  store: new KOA_PG_SESSION(process.env.DATABASE_URL),
  cookie: {
    path: "/",
    secureProxy: !process.env.IS_DEV
  }
}));

// === Setup db:
app.use(koa_pg(process.env.DATABASE_URL));

// === Finally, the routes:
app.use(mount(homepage));
app.use(mount(user));
// app.use(mount(members));
// app.use(mount(www_apps));

// === Start the server.
app.listen(port, function() {
  console.log('Listening on: ' + port);
});
