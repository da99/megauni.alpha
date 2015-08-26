"use strict";
/* jshint esnext: true, undef: true, unused: true */
/* global process, require  */


var KOA_GENERIC_SESSION = require('koa-generic-session');
var KOA_PG_SESSION      = require('koa-pg-session');

var koa              = require('koa');
var koa_static       = require('koa-static');
var helmet           = require('koa-helmet');
var mount            = require('koa-mount');
var logger           = require('koa-logger');
var koa_pg           = require('koa-pg');
var koa_bodyparser   = require('koa-bodyparser');
var koa_csrf         = require('koa-csrf');
var koa_errorhandler = require('koa-errorhandler');

var port        = process.env.PORT;
var app         = koa();
var homepage    = require('./Server/Root/homepage');
var user_routes = require('./Server/User/routes');
var csrf_routes = require('./Server/Session/csrf_routes');
// var he          = require('he');
var multiline   = require('multiline');

var fs = require('fs');
var error_pages = {
  403: fs.readFileSync('../megauni.html/Public/403.html').toString(),
  404: fs.readFileSync('../megauni.html/Public/404.html').toString(),
  500: fs.readFileSync('../megauni.html/Public/500.html').toString(),
  any: multiline.stripIndent(function () { /*
      <html>
        <head>
          <title>Error</title>
        </head>
        <body>
          Unknown Error.  Try again later.
        </body>
      </html>
    */})
};

if (process.env.IS_DEV) {
  app.use(logger());
}

// === Set security before routes:
app.use(helmet());
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

app.keys = [
  process.env.SESSION_SECRET,
  process.env.SESSION_SECRET + Math.random().toString()
];

app.use(KOA_GENERIC_SESSION({
  store: new KOA_PG_SESSION(process.env.DATABASE_URL),
  cookie: {
    httpOnly: true,
    path: "/",
    secureProxy: !process.env.IS_DEV,
    maxage: null
  }
}));

// === Setup error handling:
// === Send a generic message to client in case 'err.message'
//     contains sensitive data.
app.use(koa_errorhandler({
  debug: !process.env.IS_DEV,
  html : function () {
    this.body = error_pages[this.status] || error_pages.any;
  },
  json : function () {
    this.body = JSON.stringify({error: {tags: ['server', this.status], msg: "Unknown error."}});
  },
  text : function () {
    this.body = 'Unknown error.';
  }
}));

// === Setup CSRF:
koa_csrf(app);
app.use(koa_csrf.middleware);
app.use(mount(csrf_routes));

// === Setup db:
app.use(koa_pg(process.env.DATABASE_URL));

app.use(koa_bodyparser({jsonLimit: '250kb'}));

// === Finally, the routes:
app.use(mount(homepage));
app.use(mount(user_routes));
// app.use(mount(members));
// app.use(mount(www_apps));

// === Start the server.
app.listen(port, function() {
  console.log('Listening on: ' + port);
});

