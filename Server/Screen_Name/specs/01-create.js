"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global before, after, require, describe, it, process */
var assert   = require('assert');
var SQL      = require('named_sql');
var log; log = function () { return (process.env.IS_DEV) ? console.log.apply(console, arguments) : null; };
// var _           = require('lodash');

var Screen_Name = require('../model');
var pg = require('co-pg')(require('pg'));
var conn_done , client , app;

var Q = {
  first : function* (raw_sql, raw_vals) {
    return (yield Q.all(raw_sql, raw_vals))[0];
  },
  all : function* (raw_sql, raw_vals) {
    return (yield Q.query_(raw_sql, raw_vals)).rows;
  },
  query_ : function* (raw_sql, raw_vals) {
    var sql = SQL(raw_sql, raw_vals);
    return yield client.query_(sql.sql, sql.vals);
  },

};

describe("Screen Name: create", function () {

  before(function* () {
    var conn  = yield pg.connectPromise(process.env.DATABASE_URL);
    client    = conn[0];
    conn_done = conn[1];
    app = {pg: {db: {client: client}}};
  });

  after(function () { conn_done(); });

  it("creates record if data validates", function* () {
    var name = "name_valid_" + Date.now();
    var sn   = yield Screen_Name.create(app, {screen_name:name});
    var row  = yield Q.first('SELECT id, screen_name FROM screen_name WHERE screen_name = :screen_name', sn.data);
    assert.equal(row.screen_name, name.toUpperCase());
  });

  it("raises Invalid if screen name is empty", function* () {
    var err = {};
    try {
      yield Screen_Name.create(app, {screen_name: ''});
    } catch (e) {
      err = e;
    }

    assert(/Screen name must be/.test(err.megauni_record.errors.fields.screen_name));
  });

  it("megauni is not allowed (despite case)", function* () {
    var err = {};
    try {
      yield Screen_Name.create(app, {screen_name: 'meGauNi'});
    } catch (e) {
      err = e;
    }
    var msg = err.megauni_record.errors.fields.screen_name;
    assert(/Screen name is taken./.test(msg), 'Expected: ' + msg);
  });

  it("raises Invalid for duplicate name", function* () {
    var name = "name_invalid_" + (Date.now());
    var err = {};
    try {
      yield Screen_Name.create(app, {screen_name: name});
      yield Screen_Name.create(app, {screen_name: name});
    } catch (e) {
      err = e;
    }

    var msg = err.megauni_record.errors.fields.screen_name;
    assert(/Screen name is taken/i.test(msg), 'Expected: ' + msg);
  });

  it("updates :owner_id (of returned SN obj) to its :id if Customer is new and has no id", function* () {
    var name = "name_name_#{rand(10000)}";
    var sn = yield Screen_Name.create(app, {screen_name : name});
    assert.equal(sn.data.id, sn.data.owner_id);
  });

  // it("uses Customer :id as it's :owner_id", function* () {
    // o = Customer.create(
      // screen_name: "sn_1235_#{rand(10000)}",
      // pass_word: "this is my weak password",
      // confirm_pass_word: "this is my weak password",
      // ip: '00.000.000'
    // )
    // Screen_Name::TABLE.where(owner_id: o.data[:id]).first[:owner_id].should == o.data[:id]
  // });

}); // === describe


