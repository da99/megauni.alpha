"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global module, process */

if (process.env.IS_DEV) {
  module.exports = {
    log : function () {
      var fin = [];
      for (let v of arguments) {
        fin.push(v.toString());
      }
      return console.log.apply(console, fin);
    }
  };
} else {
  module.exports = {
    log : function () {}
  };
}
