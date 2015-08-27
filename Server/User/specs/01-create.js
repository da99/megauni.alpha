"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global before, after, require, describe, it, process */

// var multiline   = require('multiline');
// var _           = require('lodash');
var log; log = function () { return (process.env.IS_DEV) ? console.log.apply(console, arguments) : null; };
var assert   = require('assert');
var pg = require('co-pg')(require('pg'));
var conn_done , client , app;
var User = require('../model');

var PASS_WORD="this_is_my pass word";

describe('create:', function () {

  before(function* () {
    var conn  = yield pg.connectPromise(process.env.DATABASE_URL);
    client    = conn[0];
    conn_done = conn[1];
    app = {pg: {db: {client: client}}};
  });

  after(function () { conn_done(); });


  it('checks min length of screen_name', function* () {

    var err = {};
    try {
      yield User.create(app, {
        screen_name: "a",
        pass_word: "this is my password",
        confirm_pass_word: "this is my password",
        ip: '000.00.00'
      });
    } catch (e) {
      err = e;
    }

    var msg = err.megauni_record.errors.fields.screen_name;
    assert(
      /Screen name must be between [0-9]/.text(msg),
      'Expected: ' + msg
    );

  }); // === it

  it('checks max length of screen_name', function* () {
    var screen_name = "123456789012345678901234567";
    var err = {};
    try {
      yield User.create(
        app,
        { screen_name: screen_name,
        pass_word: PASS_WORD,
        confirm_pass_word: PASS_WORD,
        ip: '00.000.000' }
      );
    } catch (e) {
      err = e;
    }
    var msg = err.megauni_record.errors.fields.screen_name;
    assert(
      /Screen name must be: 4-\d\d/.test(msg),
      'Expected: ' + msg
    );
  });

  it('checks min length of pass_word', function* () {
    var new_name = "1234567";
    var err = {};
    try {
      yield User.create( app, {
        screen_name: new_name,
        pass_word: "t",
        confirm_pass_word: "t",
        ip: '000.00.00'
      });
    } catch (e) {
      err = e;
    }
    var msg = err.megauni_record.errors.fields.screen_name;
    assert(
      /Pass phrase is not long enough/.test(msg),
      'Expected: ' + msg
    );
  }); // === it

  it('checks max length of pass_word', function* () {
    var new_name = "name_name_#{rand(10000)}";
    var err = {};
    var pswd = "";
    _.times(300, function () { pswd = pswd + 'a b c'; });

    try {
      yield User.create( app, {
        screen_name: new_name,
        pass_word: pswd,
        confirm_pass_word: pswd,
        ip: '00.000.000'
      });
    } catch (e) {
      err = e;
    }
    var msg = err.megauni_record.errors.fields.screen_name;
    assert(
      /Pass phrase is too big/.test(msg),
      'Expected: ' + msg
    );
  });

  it('checks pass_phrase and confirm_pass_phrase match', function* () {
    var screen_name = "123456789";
    var err;
    try {
      yield User.create(app, {
        screen_name: screen_name,
        pass_word: PASS_WORD,
        confirm_pass_word: PASS_WORD + "a",
        ip: '00.000.000'
      });
    } catch (e) {
      err = e;
    }
    var msg = err.megauni_record.errors.fields.screen_name;
    assert(
      /Pass phrase confirmation does not match/.test(msg),
      'Expected: ' + msg
    );
  });

  it('saves Customer id to Customer object', function* () {
    var o = yield User.create(app, {
      screen_name: "sn_1235_#{rand(10000)}",
      pass_word: PASS_WORD,
      confirm_pass_word: PASS_WORD,
      ip: '00.000.000'
    });
    assert.equal(typeof o.data.id, 'number');
  });

  it("does not return :pswd_hash", function* () {
    var o = yield User.create( app, {
      screen_name: "sn_hash_#{rand(10000)}",
      pass_word: PASS_WORD,
      confirm_pass_word: PASS_WORD,
      ip: '00.000.000'
    });

    assert.equal( _.has(o.data, 'pswd_hash'), false);
    assert.equal( _.has(o.new_data, 'pswd_hash'), false);
    assert.equal( _.has(o.clean_data, 'pswd_hash'), false);
  }); // === it does not return :pswd_hash

}); // === desc create


