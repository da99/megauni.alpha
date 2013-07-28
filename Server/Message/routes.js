
var _         = require("underscore")._
, Message       = require("./model").Message
, Screen_Name = require("../Screen_Name/model").Screen_Name
, Website     = require("../Website/model").Website
, log         = require("../App/base").log
;

exports.route = function (mod) {
  var app = mod.app;

  // ============ READ =================================================
  app.get("/Message/:id", function (req, resp, next) {
    var OK            = mod.New_Request(arguments);
    var opts          = OK.template_data('Message/show_one');
    opts['title']     = "Message #" + req.params.id;
    return OK.render_template();
  });

  // ============ CREATE ===============================================
  app.post("/Message", function (req, resp, next) {
    var data = _.clone(req.body);
    mod.New_River(req, resp, next)
    .read_one('screen_name', function (j) {
      Screen_Name.read_by_screen_name(req.params.screen_name, req.user, j);
    })
    .create_one(function (j, sn) {
      Message.create_by_screen_name(sn, data, j);
    })
    .job(function (j, model) {
      resp.json({
        success : true,
        msg     : 'Created: ',
        model   : model
      });
    })
    .run();
  });

}; // ==== exports.routes





