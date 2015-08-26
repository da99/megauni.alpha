"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global require, module  */

var _     = require('lodash');

var Model = require('../Megauni/model');

var Screen_Name = function (app) {
  _.extend(this, Model.instance);
  this.init(app, 'Screen_Name');
};

_.extend(Screen_Name, Model.class);

module.exports = Screen_Name;
