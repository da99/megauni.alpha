"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global require, module  */

var _           = require('lodash');
var Model       = require('../Megauni/model');
var Screen_Name = require('../Screen_Name/model');

var User = function (app) {
  _.extend(this, Model.instance);
  this.init(app, 'User');
};

_.extend(User, Model.class);

function to_string(u) {
  return (u && u.toString()) || '';
}

User.cleaners = [];
User.cleaners.push(

  // # field(:ip) {
    // # string_ish 7, 50, /\A[0-9\.\:]+\Z/.freeze
    // # mis_match 'Invalid format for IP address: {{raw}}'
  // # }

  function () { /* pass_word */
    // pseudo
    if (this.is_new() || !_.has(this.new_data, 'pass_word'))
      return;


    var min = 10, max = 300;
    var confirm   = _.trim(to_string(this.new_data.confirm_pass_word));
    var pass_word = _.trim(to_string(this.new_data.pass_word));

    if (pass_word.length < min) {
      return this.invalid('pass_word', 'Pass phrase is not long enough: at least ' + 10 + ' characters.');
    }

    if (pass_word.length > max) {
      return this.invalid('pass_word', 'Pass phrase is too big.');
    }

    if (pass_word.split < 3) {
      return this.invalid('pass_word', 'Pass phrase must be three words or more... with spaces.');
    }

    if (confirm !== pass_word) {
      return this.invalid('confirm_pass_word', 'Pass phrase confirmation does not match with pass phrase.');
    }

    // decode "crypt( ?, pswd_hash)", val
    this.secret_data = {
      pswd_hash: {
        sequel_literal: "crypt( :PASS_WORD  , gen_salt('bf', 13))",
        PASS_WORD: pass_word
      }
    };
  },

  function* () {
    if (!this.is_new())
      return;

    var sn = yield Screen_Name.create(this.new_data);
    this.errors = sn.errors;
    if (this.is_valid())
      this.clean_data.id = sn.data.id;
  }
);




module.exports = User;

