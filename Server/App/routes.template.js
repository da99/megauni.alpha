
var _ = require("underscore")._
, Ok  = require("../Ok/model").Model
, log = require("../App/base").log
, F   = require("tally_ho").Tally_Ho
;

var MODEL     = Ok.MODEL
, Screen_Name = Ok.Screen_Name
;

exports.route = function (mod) {
  var app = mod.app;

  // ============ CREATE ===============================================

  app.post("/MODEL", function (req, resp, next) {
    var data = _.clone(req.body);
    mod.New_River(req, resp, next)
    .read_one('screen_name', function (j) {
      Screen_Name.read_by_screen_name(req.params.screen_name, req.user, j);
    })
    .create_one(function (j, sn) {
      MODEL.create_by_screen_name(sn, data, j);
    })
    .job(function (j, model) {
      resp.json({
        success : true,
        msg     : 'Created: ',
        model   : model.public_data()
      });
    })
    .run();
  });

  // ============ READ =================================================

  app.get("/MODEL/:id", function (req, resp, next) {
    var OK            = mod.New_Request(arguments);
    var opts          = OK.template_data('MODEL/show_one');
    opts['title']     = "MODEL #" + req.params.id;
    return OK.render_template();
  });

}; // ==== exports.routes





