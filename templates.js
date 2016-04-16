"use strict";
/* jshint esnext: true, undef: true, unused: true */
/* global  module  */

var templates = {"homepage":{"markup":{"attrs":{"title":"megaUNI Home"},"dir":"homepage","source":"<config title=\"megaUNI Home\" />\n\n\n    <script id=\"Welcome\" type=\"text/applet\"> \n      <div class=\"block\" show_if=\"logged_in?\">\n        <p>You are logged in.</p>\n      </div>\n    </script>\n    <script id=\"New_Session\" type=\"text/applet\">\n      <div class=\"block\" show_if=\"!logged_in?\">\n        <h3>Log-In</h3>\n        <div class=\"content\">\n          <form action=\"/sign-in\" id=\"sign_in\" method=\"post\">\n            <div class=\"fields\">\n              <div class=\"field screen_name\"><label for=\"LOGIN_SCREEN_NAME\">Screen name:</label><input name=\"screen_name\" type=\"text\" value=\"\" /></div>\n              <div class=\"field passphrase\"><label for=\"LOGIN_PASS_PHRASE\">Pass phrase:</label><input name=\"pswd\" type=\"password\" value=\"\" /></div>\n              <div class=\"field buttons\"><button class=\"submit\">Log-In</button></div>\n            </div>\n          </form>\n        </div>\n      </div>\n    </script>\n    <script id=\"New_Customer\" type=\"text/applet\">\n      <div class=\"block\" show_if=\"!logged_in?\">\n        <h3>Create a New Account</h3>\n        <div class=\"content\">\n          <form action=\"/user\" id=\"create_account\" method=\"post\">\n            <div class=\"fields\">\n              <div class=\"field screen_name\"><label for=\"NEW_CUSTOMER_SCREEN_NAME\">Screen name:</label><input name=\"screen_name\" type=\"text\" value=\"\" /></div>\n              <div class=\"field pswd\"><label for=\"NEW_CUSTOMER_PASS_PHRASE\"><span class=\"main\">Pass phrase</span><span class=\"sub\"> (for better security, use spaces and words)</span><span class=\"main\">:</span></label><input name=\"pswd\" type=\"password\" value=\"\" /></div>\n              <div class=\"field confirm_pass_phrase\"><label for=\"NEW_CUSTOMER_CONFIRM_PASS_PHRASE\"><span class=\"main\">Re-type the pass phrase:</span></label><input name=\"confirm_pass_word\" type=\"password\" value=\"\" /></div>\n              <div class=\"buttons\"><input name=\"_csrf\" type=\"hidden\" value=\"{{_csrf}}\" /><button class=\"submit\">Create Account</button></div>\n            </div>\n          </form>\n        </div>\n      </div>\n    </script>\n    <div class=\"block\" id=\"intro\">\n      <h1 class=\"site\"><span class=\"main\">mega</span><span class=\"sub\">UNI</span></h1>\n      <p><a href=\"/home\">/home</a></p>\n      <p><a href=\"/@da99\">/@da99</a></p>\n      <p><a href=\"/!4567\">/!4567</a></p>\n      <p><a href=\"/nowhere\">/nowhere</a></p>\n      <div class=\"disclaimer\">\n        <p>\n          &copy; 2012-<span id=\"copyright_year_today\">2015</span> megauni.com. Some rights reserved.\n        </p>\n        <p>All other copyrights belong to their respective owners, who have no association to this site:</p>\n        <p><span>Logo font: </span><a href=\"http://openfontlibrary.org/en/font/otfpoc\">Aghja</a></p>\n        <p><span>Palettes: </span><a href=\"http://www.colourlovers.com/lover/dvdcpd\">dvdcpd</a><a href=\"http://www.colourlovers.com/palette/154398/bedouin\">shari_foru</a></p>\n      </div>\n    </div>\n","name":"markup","code":"{code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"<config title=\\\"megaUNI Home\\\" />\");t.b(\"\\n\");t.b(\"\\n\");t.b(\"\\n\" + i);t.b(\"    <script id=\\\"Welcome\\\" type=\\\"text/applet\\\"> \");t.b(\"\\n\" + i);t.b(\"      <div class=\\\"block\\\" show_if=\\\"logged_in?\\\">\");t.b(\"\\n\" + i);t.b(\"        <p>You are logged in.</p>\");t.b(\"\\n\" + i);t.b(\"      </div>\");t.b(\"\\n\" + i);t.b(\"    </script>\");t.b(\"\\n\" + i);t.b(\"    <script id=\\\"New_Session\\\" type=\\\"text/applet\\\">\");t.b(\"\\n\" + i);t.b(\"      <div class=\\\"block\\\" show_if=\\\"!logged_in?\\\">\");t.b(\"\\n\" + i);t.b(\"        <h3>Log-In</h3>\");t.b(\"\\n\" + i);t.b(\"        <div class=\\\"content\\\">\");t.b(\"\\n\" + i);t.b(\"          <form action=\\\"/sign-in\\\" id=\\\"sign_in\\\" method=\\\"post\\\">\");t.b(\"\\n\" + i);t.b(\"            <div class=\\\"fields\\\">\");t.b(\"\\n\" + i);t.b(\"              <div class=\\\"field screen_name\\\"><label for=\\\"LOGIN_SCREEN_NAME\\\">Screen name:</label><input name=\\\"screen_name\\\" type=\\\"text\\\" value=\\\"\\\" /></div>\");t.b(\"\\n\" + i);t.b(\"              <div class=\\\"field passphrase\\\"><label for=\\\"LOGIN_PASS_PHRASE\\\">Pass phrase:</label><input name=\\\"pswd\\\" type=\\\"password\\\" value=\\\"\\\" /></div>\");t.b(\"\\n\" + i);t.b(\"              <div class=\\\"field buttons\\\"><button class=\\\"submit\\\">Log-In</button></div>\");t.b(\"\\n\" + i);t.b(\"            </div>\");t.b(\"\\n\" + i);t.b(\"          </form>\");t.b(\"\\n\" + i);t.b(\"        </div>\");t.b(\"\\n\" + i);t.b(\"      </div>\");t.b(\"\\n\" + i);t.b(\"    </script>\");t.b(\"\\n\" + i);t.b(\"    <script id=\\\"New_Customer\\\" type=\\\"text/applet\\\">\");t.b(\"\\n\" + i);t.b(\"      <div class=\\\"block\\\" show_if=\\\"!logged_in?\\\">\");t.b(\"\\n\" + i);t.b(\"        <h3>Create a New Account</h3>\");t.b(\"\\n\" + i);t.b(\"        <div class=\\\"content\\\">\");t.b(\"\\n\" + i);t.b(\"          <form action=\\\"/user\\\" id=\\\"create_account\\\" method=\\\"post\\\">\");t.b(\"\\n\" + i);t.b(\"            <div class=\\\"fields\\\">\");t.b(\"\\n\" + i);t.b(\"              <div class=\\\"field screen_name\\\"><label for=\\\"NEW_CUSTOMER_SCREEN_NAME\\\">Screen name:</label><input name=\\\"screen_name\\\" type=\\\"text\\\" value=\\\"\\\" /></div>\");t.b(\"\\n\" + i);t.b(\"              <div class=\\\"field pswd\\\"><label for=\\\"NEW_CUSTOMER_PASS_PHRASE\\\"><span class=\\\"main\\\">Pass phrase</span><span class=\\\"sub\\\"> (for better security, use spaces and words)</span><span class=\\\"main\\\">:</span></label><input name=\\\"pswd\\\" type=\\\"password\\\" value=\\\"\\\" /></div>\");t.b(\"\\n\" + i);t.b(\"              <div class=\\\"field confirm_pass_phrase\\\"><label for=\\\"NEW_CUSTOMER_CONFIRM_PASS_PHRASE\\\"><span class=\\\"main\\\">Re-type the pass phrase:</span></label><input name=\\\"confirm_pass_word\\\" type=\\\"password\\\" value=\\\"\\\" /></div>\");t.b(\"\\n\" + i);t.b(\"              <div class=\\\"buttons\\\"><input name=\\\"_csrf\\\" type=\\\"hidden\\\" value=\\\"{{_csrf}}\\\" /><button class=\\\"submit\\\">Create Account</button></div>\");t.b(\"\\n\" + i);t.b(\"            </div>\");t.b(\"\\n\" + i);t.b(\"          </form>\");t.b(\"\\n\" + i);t.b(\"        </div>\");t.b(\"\\n\" + i);t.b(\"      </div>\");t.b(\"\\n\" + i);t.b(\"    </script>\");t.b(\"\\n\" + i);t.b(\"    <div class=\\\"block\\\" id=\\\"intro\\\">\");t.b(\"\\n\" + i);t.b(\"      <h1 class=\\\"site\\\"><span class=\\\"main\\\">mega</span><span class=\\\"sub\\\">UNI</span></h1>\");t.b(\"\\n\" + i);t.b(\"      <p><a href=\\\"/home\\\">/home</a></p>\");t.b(\"\\n\" + i);t.b(\"      <p><a href=\\\"/@da99\\\">/@da99</a></p>\");t.b(\"\\n\" + i);t.b(\"      <p><a href=\\\"/!4567\\\">/!4567</a></p>\");t.b(\"\\n\" + i);t.b(\"      <p><a href=\\\"/nowhere\\\">/nowhere</a></p>\");t.b(\"\\n\" + i);t.b(\"      <div class=\\\"disclaimer\\\">\");t.b(\"\\n\" + i);t.b(\"        <p>\");t.b(\"\\n\" + i);t.b(\"          &copy; 2012-<span id=\\\"copyright_year_today\\\">2015</span> megauni.com. Some rights reserved.\");t.b(\"\\n\" + i);t.b(\"        </p>\");t.b(\"\\n\" + i);t.b(\"        <p>All other copyrights belong to their respective owners, who have no association to this site:</p>\");t.b(\"\\n\" + i);t.b(\"        <p><span>Logo font: </span><a href=\\\"http://openfontlibrary.org/en/font/otfpoc\\\">Aghja</a></p>\");t.b(\"\\n\" + i);t.b(\"        <p><span>Palettes: </span><a href=\\\"http://www.colourlovers.com/lover/dvdcpd\\\">dvdcpd</a><a href=\\\"http://www.colourlovers.com/palette/154398/bedouin\\\">shari_foru</a></p>\");t.b(\"\\n\" + i);t.b(\"      </div>\");t.b(\"\\n\" + i);t.b(\"    </div>\");t.b(\"\\n\");return t.fl(); },partials: {}, subs: {  }}","file_name":"/apps/megauni.js/Public/applets/homepage/markup.mustache"}},"MUE":{"layout":{"attrs":{},"dir":"MUE","source":"<!DOCTYPE html>\n<html>\n  <head>\n    <link href=\"/css/vanilla.reset.css\" media=\"all\" rel=\"stylesheet\" type=\"text/css\" />\n    <link href=\"/css/fonts.css\" media=\"all\" rel=\"stylesheet\" type=\"text/css\" />\n    <link href=\"/css/otfpoc.css\" media=\"all\" rel=\"stylesheet\" type=\"text/css\" />\n    <link href=\"/applets/MUE/style.css\" media=\"all\" rel=\"stylesheet\" type=\"text/css\" />\n    <link href=\"/applets/homepage/style.css\" media=\"all\" rel=\"stylesheet\" type=\"text/css\" />\n    <title>[[ title ]]</title>\n  </head>\n  <body>\n    [[> markup ]]\n    <script src=\"/scripts/jquery/dist/jquery.min.js\"></script>\n    <script src=\"/scripts/lodash/lodash.min.js\"></script>\n    <script src=\"/scripts/da99.applet.js/applet.js\"></script>\n  </body>\n</html>\n\n","name":"layout","code":"{code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"<!DOCTYPE html>\");t.b(\"\\n\" + i);t.b(\"<html>\");t.b(\"\\n\" + i);t.b(\"  <head>\");t.b(\"\\n\" + i);t.b(\"    <link href=\\\"/css/vanilla.reset.css\\\" media=\\\"all\\\" rel=\\\"stylesheet\\\" type=\\\"text/css\\\" />\");t.b(\"\\n\" + i);t.b(\"    <link href=\\\"/css/fonts.css\\\" media=\\\"all\\\" rel=\\\"stylesheet\\\" type=\\\"text/css\\\" />\");t.b(\"\\n\" + i);t.b(\"    <link href=\\\"/css/otfpoc.css\\\" media=\\\"all\\\" rel=\\\"stylesheet\\\" type=\\\"text/css\\\" />\");t.b(\"\\n\" + i);t.b(\"    <link href=\\\"/applets/MUE/style.css\\\" media=\\\"all\\\" rel=\\\"stylesheet\\\" type=\\\"text/css\\\" />\");t.b(\"\\n\" + i);t.b(\"    <link href=\\\"/applets/homepage/style.css\\\" media=\\\"all\\\" rel=\\\"stylesheet\\\" type=\\\"text/css\\\" />\");t.b(\"\\n\" + i);t.b(\"    <title>\");t.b(t.v(t.f(\"title\",c,p,0)));t.b(\"</title>\");t.b(\"\\n\" + i);t.b(\"  </head>\");t.b(\"\\n\" + i);t.b(\"  <body>\");t.b(\"\\n\" + i);t.b(t.rp(\"<markup0\",c,p,\"    \"));t.b(\"    <script src=\\\"/scripts/jquery/dist/jquery.min.js\\\"></script>\");t.b(\"\\n\" + i);t.b(\"    <script src=\\\"/scripts/lodash/lodash.min.js\\\"></script>\");t.b(\"\\n\" + i);t.b(\"    <script src=\\\"/scripts/da99.applet.js/applet.js\\\"></script>\");t.b(\"\\n\" + i);t.b(\"  </body>\");t.b(\"\\n\" + i);t.b(\"</html>\");t.b(\"\\n\");t.b(\"\\n\");return t.fl(); },partials: {\"<markup0\":{name:\"markup\", partials: {}, subs: {  }}}, subs: {  }}","file_name":"/apps/megauni.js/Public/applets/MUE/layout.mustache"}}};

module.exports = templates;