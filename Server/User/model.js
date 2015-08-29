"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global require, module  */
var log; log = require('../Megauni/console').log;

var _           = require('lodash');
var Model       = require('../Megauni/model');
var Screen_Name = require('../Screen_Name/model');
var to_string   = function (u) { return (u && u.toString()) || ''; };
var bcrypt      = require('co-bcrypt');



class User extends Model {
} // === class User

User.Blowfish = 13;

User.on(
  'data_clean',

  // # field(:ip) {
    // # string_ish 7, 50, /\A[0-9\.\:]+\Z/.freeze
    // # mis_match 'Invalid format for IP address: {{raw}}'
  // # }

  function () { /* pass_word */

    if (!this.is_new() || !_.has(this.new_data, 'pass_word'))
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

    this.secret.take( 'pass_word', 'confirm_pass_word' );
  },

  function* () {
    if (!this.is_new())
      return;

    var sn = yield Screen_Name.create(this.app, this.new_data);
    this.error = sn.error;
    if (!this.error)
      this.clean.id = sn.data.id;

    this.secret.set(
      'pswd_hash',
      yield bcrypt.hash(
        this.secret.delete('pass_word'),
        yield bcrypt.genSalt(User.Blowfish)
      )
    );

    this.db_insert_sql = `
      -- Inspired from: http://www.neilconway.org/docs/sequences/
      INSERT INTO
        :idents.TABLE ( :clean.COLS! , pswd_hash         )
        VALUES        ( :clean.VALS! , :secret.pswd_hash )
      RETURNING
        :clean.COLS! ;
    `;

  }
); // == on data_clean


module.exports = User;

