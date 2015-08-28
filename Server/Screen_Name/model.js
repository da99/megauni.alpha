"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global require, module  */

/* global process */
var log; log = function (...args) { return (process.env.IS_DEV) ? console.log.apply(console, args) : null; };

// var _     = require('lodash');
var Model = require('../Megauni/model');

// const WORLD     = 1;
// const PROTECTED = 2;
// const PRIVATE   = 3;

// const  BEGIN_AT_OR_HASH    = /\A(\@|\#)/ ;
// const  ALL_WHITE_SPACE     = /\s+/ ;
const  VALID               = /^[a-zA-Z0-9\-\_\.]{4,30}$/i ;
const  VALID_ENGLISH       = "Screen name must be 4 to 30 characters: numbers, letters, underscores, dash, or periods.";
const  BANNED_SCREEN_NAMES = [
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
];

class Screen_Name extends Model{

} // === class Screen_Name

Screen_Name.on(
  'data_clean',
  function () {
    if (!this.is_new()) {
      return;
    }

    var KEY = 'screen_name';

    var val = (this.new_data.screen_name || '').toString().trim().toUpperCase();

    if (!(VALID.test(val)))
      return this.error_msg(KEY, VALID_ENGLISH);

    for (let regexp of BANNED_SCREEN_NAMES) {
      if (regexp.test(val))
        return this.error_msg(KEY, 'Screen name is taken.');
    }

    this.clean[KEY] = val;
    this.clean.display_name = val;
    // unique_index 'screen_name_unique_idx', "Screen name already taken: {{val}}"
  },

  function () {
    if (!(this.is_new() && !this.clean.owner_id))
      return;

    this.db_insert_sql = `
      -- Inspired from: http://www.neilconway.org/docs/sequences/
      INSERT INTO :idents.TABLE ( :clean.COLS! , owner_id )
      VALUES ( :clean.VALS! , CURRVAL(PG_GET_SERIAL_SEQUENCE( ':idents.TABLE', 'id' )) )
      RETURNING :clean.COLS! , id , owner_id ;
    `;

  } // === set owner_id = id
); // === on data_clean

Screen_Name.on(
  'db_error',
  function (e) {
    if (!(this.is_new() && /screen_name_unique_idx/.test(e.message)))
      return;
    return this.error_msg('screen_name', 'Screen name is taken.');
  }
); // === on db_error

module.exports = Screen_Name;








