"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global require, module  */
/* global process */
var log; log = function () { return (process.env.IS_DEV) ? console.log.apply(console, arguments) : null; };

var _           = require('lodash');
var Model       = require('../Megauni/model');
var Screen_Name = require('../Screen_Name/model');
var to_string   = function (u) { return (u && u.toString()) || ''; };



class User extends Model {
} // === class User

User.on(
  'data_clean',

  // # field(:ip) {
    // # string_ish 7, 50, /\A[0-9\.\:]+\Z/.freeze
    // # mis_match 'Invalid format for IP address: {{raw}}'
  // # }

  function () { /* pass_word */
    if (this.is_new() || !_.has(this.new_data, 'pass_word'))
      return;


    var min = 10, max = 300;
    var confirm   = to_string(this.new_data.confirm_pass_word).trim();
    var pass_word = to_string(this.new_data.pass_word).trim();

    if (pass_word.length < min) {
      return this.error_msg('pass_word', `Pass phrase is not long enough: at least ${min} characters.`);
    }

    if (pass_word.length > max) {
      return this.error_msg('pass_word', 'Pass phrase is too big.');
    }

    if (pass_word.split < 3) {
      return this.error_msg('pass_word', 'Pass phrase must be three words or more... with spaces.');
    }

    if (confirm !== pass_word) {
      return this.error_msg('confirm_pass_word', 'Pass phrase confirmation does not match with pass phrase.');
    }

    // decode "crypt( ?, pswd_hash)", val
    this.db_insert_sql = `
      -- Inspired from: http://www.neilconway.org/docs/sequences/
      INSERT INTO
        :idents.TABLE ( :clean.COLS! , pswd_hash )
        VALUES ( :clean.VALS! , crypt( :secret.PASS_WORD  , gen_salt('bf', 13)) )
      RETURNING :COLS! ;
    `;

    this.secret.PASS_WORD = pass_word;
  },

  function* () {
    if (!this.is_new())
      return;

    var sn = yield Screen_Name.create(this.new_data);
    this.error = sn.error;
    if (this.is_valid())
      this.clean.id = sn.data.id;
  }
); // == on data_clean


module.exports = User;

