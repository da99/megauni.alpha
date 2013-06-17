var _ = require("underscore"),
Customer = require("../Customer/model").Customer
;

module.exports.route = function (mod) {

  var app = mod.app;

  app.post('/account', function (req, resp, next) {
    var r = mod.New_River(arguments);
    r.job(function (j) {
      Customer.create({
        screen_name         : req.body.screen_name,
        display_name        : req.body.screen_name,
        ip                  : req.ip,
        pass_phrase         : req.body.pass_phrase,
        confirm_pass_phrase : req.body.confirm_pass_phrase
      }, j);
    })
    .run(function (r, last) {
      var sn = last.screen_names()[0];
      sign_in(req, resp, next);
    });
  });

}; // === exports.route




