"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global module, require  */

var _   = require('lodash');
var SQL = require('named_sql');
var multiline = require('multiline');

module.exports = {
  instance: {

    init : function () {
      this.errors     = {};
      this.data       = {};
      this.new_data   = {};
      this.clean_data = {};
    },

    clean : function (new_data) {
      this.new_data   = new_data;
      this.clean_data = {};
      _.detect(this.cleaners, function (f) {
        f.apply(this);
        return !this.is_valid();
      });
      return this;
    },

    is_valid : function () {
      return _.isEmpty(this.errors);
    },

    is_new : function () {
      return _.has(this.data, 'id');
    }, // === func is_new

    invalid : function (col, msg) {
      if (!this.errors.fields)
        this.errors.fields = {};
      this.errors.fields[col] = msg;
      return this;
    },

    db_insert : function* (app, new_data, sql_str) {

      this.new_data = new_data;
      this.clean();

      sql_str = sql_str || SQL(
        this.clean_data,
        {TABLE : this.table_name},
        multiline(function () {/*
          INSERT INTO :TABLE ( :COLS )
          VALUES ( :VALS )
          RETURNING * ;
        */})
      );

      if (this.is_valid()) {
        yield app.pg.db.query_(sql_str);
      }

      return this;
    }, // === func save

    db_update : function* (app) {
      yield app.pg.db.query_(SQL());
      throw new Error('not ready');
    } // === func _save_new

  } // === instance

}; // === module.exports
