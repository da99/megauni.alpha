"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global require, module  */

var _     = require('lodash');
var Model = require('../Megauni/model');

var User = function () {
  _.extend(this, Model.instance);
  this.init();
  this.table_name = 'user';
};

User.cleaners = [];
User.cleaners.push(

  function () { /* pass_word */
    // pseudo
    if (this.is_new() || !_.has(this.new_data, 'pass_word'))
      return;

    var min = 10, max = 300;
    this.clean_data.pass_word = _.trim(this.new_data.pass_word || '');

    if (this.clean_data.pass_word.length < min) {
      this.invalid('pass_word', 'Pass phrase is not long enough: at least ' + 10 + ' characters.');
    }

    if (this.clean_data.pass_word.length > max) {
      this.invalid('pass_word', 'Pass phrase is too big.');
    }

    if (this.clean_data.pass_word.split < 3) {
      this.invalid('pass_word', 'Pass phrase must be three words or more... with spaces.');
    }
  },

  function () {
    if (!this.is_new())
      return;

  }
);




module.exports = User;

