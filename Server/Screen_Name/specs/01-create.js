"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global before, after, require, describe, it, process */
var assert      = require('assert');
var SQL         = require('named_sql');
// var multiline   = require('multiline');
// var _           = require('lodash');
// var co          = require('co');
var Screen_Name = require('../model');
var pg = require('co-pg')(require('pg'));

var conn_done, client, app;

var log; log = function () { return (process.env.IS_DEV) ? console.log.apply(console, arguments) : null; };

// function throw_err(done) {
  // return function (err) {
    // console.error(err.stack);
    // if (done) done();
  // };
// }


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

  after(function () {
    conn_done();
  });

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

  // it("megauni is not allowed (despite case)", function () {
    // catch(:invalid) {
      // Screen_Name.create(screen_name: 'meGauNi')
    // }.
    // error[:msg].
    // should.match(/Screen name not allowed: /)
  // });

  // it("raises Invalid for duplicate name", function () {
    // name = "name_invalid_#{rand(10000)}"
    // catch(:invalid) {
      // Screen_Name.create(:screen_name=>name)
      // Screen_Name.create(:screen_name=>name)
    // }.
    // error[:msg].
    // should.match(/Screen name already taken: #{name}/i)
  // });

  // it("updates :owner_id (of returned SN obj) to its :id if Customer is new and has no id", function () {
    // name = "name_name_#{rand(10000)}"
    // sn = Screen_Name.create(:screen_name=>name)
    // sn.data[:id].should == sn.data[:owner_id]
  // });

  // it("uses Customer :id as it's :owner_id", function () {
    // o = Customer.create(
      // screen_name: "sn_1235_#{rand(10000)}",
      // pass_word: "this is my weak password",
      // confirm_pass_word: "this is my weak password",
      // ip: '00.000.000'
    // )
    // Screen_Name::TABLE.where(owner_id: o.data[:id]).first[:owner_id].should == o.data[:id]
  // });

}); // === describe


