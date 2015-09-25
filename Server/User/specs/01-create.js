,

  {
    "it":  "uses User :id as it's :owner_id",
    "input" : {
      "screen_name"       : "create rand: screen_name",
      "pass_word"         : "this is my weak password",
      "confirm_pass_word" : "this is my weak password",
      "ip"                : "00.000.0.00"
    },
    "output": [
      "Screen_Name.read", { "screen_name": "screen_name" },
      {"owner_id" : "user.data.id"}
    ]
  }


"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global before, after, require, describe, it, process */

// var multiline   = require('multiline');
var _        = require('lodash');
var log; log = function (...args) { return (process.env.IS_DEV) ? console.log.apply(console, args) : null; };
var assert   = require('assert');
var User     = require('../model');
var pg       = require('co-pg')(require('pg'));
var conn_done , client , app;

var PASS_WORD="this_is_my pass word";

if (!assert.regexp)
  assert.regexp = function (r, txt) { assert( r.test(txt), `"${r}" !~ "${txt}"`); };

function col(err, col_name) {
  if (!err.megauni || !err.megauni.record || !err.megauni.record.error)
    return err.message;
  return err.megauni.record.error[col_name];
}

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

    var msg = err.megauni.record.error.screen_name;
    assert(
      /Screen name must be [0-9] to [0-9]+/.test(msg),
      'Expected: ' + msg
    );

  }); // === it

  it('checks max length of screen_name', function* () {
    var screen_name = `abcd56789012345678901234567${Date.now()}`;
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
    var msg = err.megauni.record.error.screen_name;
    var r   = /Screen name must be \d to \d\d/;
    assert(
      r.test(msg),
      `"${r}" != "${msg}"`
    );
  });

  it('checks min length of pass_word', function* () {
    var new_name = `1234567${Date.now()}` ;
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

    assert.regexp(
      /Pass phrase is not long enough/,
      col(err, 'pass_word')
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
    assert.regexp( /Pass phrase is too big/, col(err, 'pass_word'));
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
    assert(
      /Pass phrase confirmation does not match/,
      col(err, 'pass_word')
    );
  });

  it('saves Customer id to Customer object', function* () {
    var o = yield User.create(app, {
      screen_name: `sn_1235_${Date.now()}`,
      pass_word: PASS_WORD,
      confirm_pass_word: PASS_WORD,
      ip: '00.000.000'
    });
    assert.equal(typeof o.data.id, 'number');
  });

  it("does not return :pswd_hash", function* () {
    var o = yield User.create( app, {
      screen_name: `sn_hash_${Date.now()}`,
      pass_word: PASS_WORD,
      confirm_pass_word: PASS_WORD,
      ip: '00.000.000'
    });

    assert.equal( _.has(o.data, 'pswd_hash'), false);
    assert.equal( _.has(o.new_data, 'pswd_hash'), false);
    assert.equal( _.has(o.clean_data, 'pswd_hash'), false);
  }); // === it does not return :pswd_hash

}); // === desc create


