var blade = require('blade');


// ================================================================
// ================== Require the Packages ========================
// ================================================================


var _         = require('underscore')
, Topogo      = require('topogo').Topogo
, River       = require('da_river').River
;

var Customer  = require('../Customer/model').Customer
, Screen_Name = require('../Screen_Name/model').Screen_Name
, Chat_Bot    = require('../Chat/Chat_Bot').Chat_Bot
;

var log       = require('./base').log
;


var password_hash = require('password-hash')
, passport        = require('passport')
, LocalStrategy   = require('passport-local').Strategy
;

var express = require('express');
var toobusy = require('toobusy');
var app     = module.exports.app = express();

// ================================================================
// ================== Helpers =====================================
// ================================================================


var New_River = exports.New_River = function (req, resp, next) {
  if (req.length) {
    resp = req[1];
    next = req[2];
    req  = req[0];
  }
  var r = River.new(null);
  r.next('invalid', function (j) {
    resp.json({success: false, msg: j.job.error.message});
  });
  return r;
};

var New_Request = exports.New_Request = function (raw_args, raw_resp, raw_next) {
  if (raw_args.length) {
    var req = raw_args[0], resp = raw_args[1], next = raw_args[2];
  } else {
    var req = raw_args, resp = raw_resp, next = raw_next;
  };

  return {
    status : function (code) {
      if (code)
        this._status = code;
      return this._status || 200;
    },
    html:  function (str) {
      this.last_modified_now();
      this.ETag_from(str);
      resp.send(str);
    },
    text: function (str) {
      resp.set('Content-Type', 'text/plain');
      this.last_modified_now();
      this.ETag_from(str);
      return resp.send(str);
    },
    json: function (data, stat) {
      this.last_modified_now();
      this.ETag_from(data);
      if (stat)
        resp.status(stat);
      resp.json(data);
    },
    json_success: function (msg, o) {
      if (!o)
        o = {};
      o.msg     = msg;
      o.success = true;
      this.json(o);
    },
    json_fail: function (msg, o, stat) {
      if (!o)
        o = {};
      o.msg     = msg;
      o.success = false;
      this.json(o, (stat || 404));
    },
    template_data : function (name, data) {
      if (!this._template_data) {
        var opts = this._template_data = {
          homepage_belongs_to_viewer: false,
          template_name : name,
          logged_in     : !!req.user,
          customer      : req.user,
          screen_name   : req.params.screen_name,
          screen_names  : [],
          is_owner      : false,
          token         : req.session._csrf,
          _csrf         : req.session._csrf,
          aud           : req.user,
          is_testing    : !!process.env.IS_TESTING
        };

        if (opts.logged_in)
          opts.screen_names = req.user.screen_names().slice().reverse();

        if (opts.logged_in && opts.screen_name)
          opts.is_owner = req.user.is(opts.screen_name);
      }
      if (data)
        _.extend(this._template_data, data);
      return this._template_data;
    },
    last_modified_now : function () {
      resp.set('Last-Modified', (new Date).toUTCString());
    },
    ETag_from : function (data) {
      resp.set('ETag', (new Date).getTime().toString());
    },
    render_template: function (name, data) {
      if (name)
        this.template_data.apply(this, arguments);
      this.last_modified_now();
      return resp.render(this.template_data().template_name, this.template_data());
    }
  };
};





// ================================================================
// ================== Basic Options ==============================*
// ================================================================


var shutting_down = false;
var tell = function () { log(' ---- '); };

var app_dir = __dirname.split('/');
app_dir.pop();
app_dir.pop();
app_dir = app_dir.join('/');

var port    = process.env.PORT || 5555;
var secret  = process.env.SESSION_SECRET;
var db_conn = process.env.DATABASE_URL;
var ip_addr = process.env.NODE_IP_FOR_AUTH;

if (!secret)
  throw new Error('No session secret set.');
if (!db_conn)
  throw new Error('No db conn string set.');
if (!ip_addr)
  throw new Error('No ip auth set.');


app.configure(function () {

  // Settings:
  app.set('view engine', 'blade');
  app.set('views', app_dir + '/Client');
  app.locals.pretty = true;

  // ================================================================
  // ================== Middleware==================================*
  // ================================================================

  // Close persistent client connections:
  app.use(function (req, resp, next) {
    if (shutting_down)
      resp.setHeader('Connection', 'close');
    next();
  });

  // Logging:
  if (process.env.IS_DEV)
    app.use(express.logger('dev'));

  // Too busy:
  app.use(function (req, resp, next) { // must go on top of other middleware
    if (toobusy()) {
      log('Too busy to send: ' + req.path);
      if (req.accepts('json')) {
        var OK = New_Request(arguments);
        OK.json_fail("Too busy", 503, {too_busy: true});
      } else
        resp.send(503, "Website is busy right now. Try again later.");
    } else
      next();
  });

  // app.use(express.errorHandler());


  // Static files:
  if (process.env.IS_HEROKU) {
    app.use(express.favicon(app_dir + '/Client/favicon.ico'));
    app.use('/', express.static(app_dir + '/Client' ));
  }

  // Dynamic stuff:
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser());

  // Session:
  app.use(express.cookieSession({secret: secret + secret}));
  app.use(express.csrf());

  // Passport:
  // Must go after session middleware.
  app.use(passport.initialize());
  app.use(passport.session());

  // Caching:
  app.use(function (req, resp, next) {
    if (req.accepts('html')) {
      resp.set("Expires", "Tue, 03 Jul 2001 06:00:00 GMT");
      resp.set("Last-Modified", "Wed, 15 Nov 1995 04:58:08 GMT");
      resp.set("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0, post-check=0, pre-check=0");
      resp.set("Pragma", "no-cache");
    }
    next();
  });

  // Make sure user is not pretending to be someone else.
  app.use(function (req, resp, next) {

    if (req.user && req.body.hasOwnProperty('as_this_life'))
      req.body.life_id = req.user.screen_name_id(req.body.as_this_life, -1);

    next();
  });

  app.use(app.router)

});


// ================================================================
// ================== Session Config: =============================
// ================================================================

passport.serializeUser(function (user, done) { done(null, user.data.id); });

passport.deserializeUser(function (id, done) {
  var on_err = function (err) {
  };

  River.new(null)
  .next('not_found', function (j) {
    done(null, false, {success: false, msg: "Not found."});
  })
  .job(function (j) {
    Customer.read_by_id(id, j);
  })
  .job(function (j, last) {
    done(null, last);
  })
  .run();
});

passport.use(new LocalStrategy( { usernameField: 'screen_name', passwordField: 'pass_phrase' }, function (screen_name, pass_phrase, done) {
  River.new(null)
  .next('not_found', function (j) {
    done(null, false, {success:false, message: "Not found."});
  })
  .job(function (j) {
    Customer.read_by_screen_name({screen_name: screen_name, pass_phrase: pass_phrase }, j);
  })
  .job(function (j, c) {
    done(null, c);
  })
  .run();
}));

module.exports.sign_in = function (req, resp, next, msg) {
  return passport.authenticate('local', function(err, user, info) {
    if (err)
      return next(err);

    if (!user) {
      return resp.json( { msg: "Screen name or pass phrase was wrong. Check your spelling.", success: false } );
    }

    req.login(user, function(err) {
      if (err)
        return next(err);
      req.session.pref_screen_name = req.body.screen_name;
      resp.json({
        msg         : msg || "Success: Please wait as page reloads...",
        success     : true,
        screen_name : req.body.screen_name,
        location    : "/me/" + req.body.screen_name
      });
    });

  })(req, resp, next);
};

// ================================================================
// ================== Helpers: ====================================
// ================================================================

var require_log_in = function (req, resp, next) {
  if (!req.user)
    return resp.redirect(307, "/");
  next();
};


// ================================================================
// ================== Routes: ====================================*
// ================================================================

// _.each(['Site', 'Chat', 'Posts', 'Screen_Names'], function (name) {
  // require('./routes/' + name);
// });
// app.get('/', function (req, resp, next) {
  // // resp.render('index', {title: "somet", template_name: "index", logged_in: false});
  // resp.header("Last-Modified", "Thu, 16 Nov 1995 04:59:09 GMT");
  // resp.send(200, "huuuml");
// });

// if (process.env.IS_TESTING)
  // require('../Test/routes');


require('../Session/routes').route(module.exports);
require('../Site/routes').route(module.exports);
require('../Customer/routes').route(module.exports);
require('../Screen_Name/routes').route(module.exports);
require('../Folder/routes').route(module.exports);






// ================================================================
// ================== ERRORS ======================================
// ================================================================

app.use(function (req, resp, next) {
  log('params: ', req.params)
  log('body: ', req.body)

  if (req.accepts('html')) {
    resp.writeHead(404, { "Content-Type": "text/html" });
    resp.end("<html><head><title>" + req.path + " : Not Found</title></head><body>Not found. Check spelling of the address.</body></html>");
  } else {
    if (req.accepts('application/json')) {
      var OK = New_Request(arguments);
      OK.json_fail("Page not found.", 404)
    } else {
      resp.writeHead(404, { "Content-Type": "text/plain" });
      resp.end(req.path + " : Not Found. Check spelling of the address.");
    }
  }
});



app.use(function (err, req, resp, next) {
  log(err.stack);

  if (req.body && req.body.request_type == 'latest msgs') {
    var OK = New_Request(req, resp, next);
    this.json( { _csrf: req.session._csrf, success: false, msg: err.toString() } );
    return true;
  };

  resp.send((err.status || 500), "Something broke. Try later.");
});



// ====================================================
//                 The End
// ====================================================
app.listen(port, function () {
  log('Listening on: ' + port);
});

function screen_names(arr) {
  var names = {first: arr[0], list: arr, multi : (arr.length != 1) };
  return names;
};


exports.app    = app;

// setInterval(Chat_Bot.send_ims, 4000);






