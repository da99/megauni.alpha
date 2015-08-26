"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global require, module  */

/* global process */
var log; log = function () { return (process.env.IS_DEV) ? console.log.apply(console, arguments) : null; };

// var _     = require('lodash');

var Model = require('../Megauni/model');

var Screen_Name = new Model('Screen_Name');

module.exports = Screen_Name;
