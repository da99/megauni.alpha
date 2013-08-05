
var _ = require("underscore")._
, Ok  = require("../Ok/model").Model
, log = require("../App/base").log
, F   = require("tally_ho").Tally_Ho
;

var Bot       = Ok.Bot
, Bot_Use     = Ok.Bot_Use
, Bot_Code    = Ok.Bot_Code
, Screen_Name = Ok.Screen_Name
;

exports.route = function (mod) {
  var app = mod.app;

  // ============ CREATE ===============================================

  app.post('/Bot', function (req, resp, next) {
    var data = {sub_sn: req.body.sub_sn, as_this_life: req.body.as_this_life, user: req.user};
    F.run('create Bot', data, function (f) {
      var bot = f.last.public_data();
      return resp.json({success: true, msg: "Bot created: " + bot.screen_name, bot: bot});
    });
  });

  app.post('/Bot/Use', function (req, resp, next) {
    mod.New_River(req, resp, next)
    .job('create', function (j) {
      Bot_Use.create({
        bot   : req.body.bot,
        owner : req.body.as_this_life
      }, j);
    })
    .run(function (fin, o) {
      var use = o.public_data();
      return resp.json({
        success: true,
        msg: 'You are now using, ' + use.screen_name + ', with ' + use.owner + '.'
      });
    });
  });


  // ============ READ =================================================

  app.get('/bot/:screen_name', function (req, resp, next) {

    var sn = req.params.screen_name;

    req.Ok.run(
      'read Bot by screen name', {screen_name: sn},
      resp.Ok.if_not_found("Bot not found: " + sn),
      'attach Bot_Code',
      function (o) {
        var bot = o.val;

        resp.Ok.render_template('Bot/bot', {
          bot      : bot.public_data(),
          title    : bot.screen_name,
          Bot_Code : Bot_Code
        });
      }
    );

  }); // === end

  app.get('/bots/for/:screen_name', function (req, resp, next) {
    mod.New_River(req, resp, next)
    .job('read', function (j) {
      Bot.read_list_to_run(req.params.screen_name, j);
    })
    .run(function (fin, list) {
      return resp.json({
        success: true,
        msg: "List read.",
        bots: list
      });
    });
  });

  // ============ UPDATE ===============================================

  app.put('/Bot', function (req, resp, next) {
    mod.New_River(req, resp, next)
    .job('update', function (j) {
      Bot.update({
        sub_sn : req.body.sub_sn,
        owner  : req.body.as_this_life,
        code   : req.body.code
      }, j);
    })
    .run(function (j, last) {
      var bot = last.public_data();
      resp.json({success: true, msg: "Update successful.", bot: bot});
    });
  });

  app.put('/Bot/Code', function (req, resp, next) {
    F.run("update Bot Code", {aud: req.user, data: req.body}, function () {
      resp.json({success: false, msg: req.body.type});
    });
  });

}; // ==== exports.routes





