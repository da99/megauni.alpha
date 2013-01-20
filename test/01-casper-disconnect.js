//
//
//  Main purpose of this file: What happens when server
//     does not start?
//
//

var opts = {
  verbose: true,
  logLevel: "info",
  onError: function (self, m) {
    console.log('FATAL: ' + m);
    self.exit();
  }
};

var base_funcs = require("/home/da/imp/MyLife/apps/SITES/okdoki/test/casper_base");
var exists = base_funcs.create_exists;
var test   = base_funcs.create_test;
var casper = require('casper').create(opts);
var base_url = 'http://localhost:' + casper.cli.args[0];
var phrase = 'Hoppe gives us hope';
var contact = "someone@miniuni.zbc"

base_funcs.prepare(casper);

// === Load page.
var msg = function () {
  return document.querySelector('#sign_in div.errors').innerHTML;
};

casper.start(base_url + '/', function () {
  this.test.assertHttpStatus(200);
});


casper.waitFor( function () {
  var errors = this.evaluate(function () {
    return document.querySelector('#sign_in div.errors');
  });
  if (errors && errors.innerHTML.match(/Check internet/) ) {
    return true;
  } else {
    this.click('#sign_in button.submit');
    return false;
  }
}, function () {
  var form = 'form#form_sign_in';
  var div_errors = form + ' div.errors';

  // === Check error message when connection is off.
  var errors = this.evaluate(function () {
    return document.querySelector('#sign_in div.errors');
  });

  this.test.assertEquals(errors.innerHTML,"error: Check internet connection. Either that or OKdoki.com is down.", "Err msg shown: check conn." );
}, null, 3000);


casper.run(function () {
  this.test.renderResults(true);
});





