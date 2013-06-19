
var _    = require('underscore')
, Folder = require("../Folder/model").Folder
;


exports.route = function (mod) {
  var app = mod.app;

  app.post('/folder', function (req, resp, next) {
    mod.New_River(req, resp, next)
    .job(function (j) {
      Folder.create({
        owner_id: req.user.data.id,
        title: req.body.title,
        website_id: req.body.website_id
      }, j);
    })
    .job(function (j, f) {
      resp.json({
        success: true,
        msg: "Folder was created.",
        title: f.data.title,
        num: f.data.num
      });
    })
    .run();
  });

  app.get('/me/:screen_name/folder/:num', function (req, resp, next) {
    var num  = parseInt(req.params.num);
    var OK   = mod.New_Request(req, resp, next);
    var opts = OK.template_data('Folder/show_one')
    var sn   = req.params.screen_name;

    mod.New_River(req, resp, next)
    .job(function (j, website) {
      Folder.read_by_screen_name_and_num( sn, num, j);
    })
    .job(function (j, f) {
      console.log(f.data);
      opts['title']            = f.data.title;
      opts['folder_num']       = num;
      opts['website_location'] = "/me/" + sn;
      opts['pages']            = f.data.pages;
        // { location: "/me/GO99/folder/1/page/3",
          // created_at: (new Date).getTime(),
          // title: "Page 3"},

      OK.render_template();
    })
    .run();
  });


}; // route
