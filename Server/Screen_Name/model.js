"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global require, module  */

/* global process */
var log; log = function () { return (process.env.IS_DEV) ? console.log.apply(console, arguments) : null; };

var _           = require('lodash');
var Model       = require('../Megauni/model');
var Screen_Name = new Model('Screen_Name');
var multiline   = require('multiline');

module.exports = Screen_Name;

_.extend(Screen_Name, {
  WORLD     : 1,
  PROTECTED : 2,
  PRIVATE   : 3,

  BEGIN_AT_OR_HASH    : /\A(\@|\#)/ ,
  ALL_WHITE_SPACE     : /\s+/ ,
  VALID               : /^[a-zA-Z0-9\-\_\.]{4,30}$/i ,
  VALID_ENGLISH       : "Screen name must be: 4-30 characters: numbers, letters, underscores, dash, or periods.",
  BANNED_SCREEN_NAMES : [
    /^MEGAUNI/i,
    /^MINIUNI/i,
    /^OKDOKI/i,
    /\A(ME|MINE|MY|MI|i)\z/i,
    /^PET-/i,
    /^BOT-/i,
    /^okjak/i,
    /^okjon/i,
    /^(ONLINE|CONTACT|INFO|OFFICIAL|ABOUT|NEWS|HOME)\z/i,
    /^(UNDEFINED|DEF|SEX|SEXY|XXX|TED|LARRY)\z/i,
    /^[.]+-COLA\z/i
  ]
});

Screen_Name.cleaners.push(
  function () {
    if (!this.is_new()) {
      return;
    }

    var KEY = 'screen_name';

    var val = _.trim((this.new_data.screen_name || '').toString()).toUpperCase();

    if (!(Screen_Name.VALID.test(val)))
      return this.invalid(KEY, Screen_Name.VALID_ENGLISH);

    if (_.detect(Screen_Name.BANNED_SCREEN_NAMES, function (regexp) { return regexp.test(val); })) {
      return this.invalid(KEY, 'Screen name already taken.');
    }

    this.clean_data[KEY] = val;
    this.clean_data.display_name = val;
    // unique_index 'screen_name_unique_idx', "Screen name already taken: {{val}}"
  },

  function () {
    if (!(this.is_new() && !this.clean_data.owner_id))
      return;

    this.db_insert_sql = multiline(function () {/*
      -- Inspired from: http://www.neilconway.org/docs/sequences/
      INSERT INTO :TABLE ( :COLS! , owner_id )
      VALUES ( :VALS! , CURRVAL(PG_GET_SERIAL_SEQUENCE( ':TABLE', 'id' )) )
      RETURNING *;
    */});

  } // === set owner_id = id

);








