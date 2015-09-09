"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global before, after, require, describe, it, process */
// var _           = require('lodash');
var log; log = function (...args) { return (process.env.IS_DEV) ? console.log.apply(console, args) : null; };
var assert   = require('assert');
var SQL      = require('named_sql');

var Screen_Name = require('../model');
var User        = require('../../User/model');
var pg = require('co-pg')(require('pg'));
var conn_done , client , app;

describe('Screen_name: read', function () {

  before(function* () {
    var conn  = yield pg.connectPromise(process.env.DATABASE_URL);
    client    = conn[0];

    conn_done = conn[1];
    app = {pg: {db: {client: client}}};
  });

  it("returns array of Screen_Name objects when first/only arg is a Customer", function () {
    o = create_screen_name
    c = o[:c]
    arr = Screen_Name.read(c).map(&:screen_name).sort
    target = Screen_Name::TABLE.where(:owner_id=>c.id).all.map { |r| r[:screen_name] }.sort
    arr.should == target
  });

}); // === describe Screen_name =================






