"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global module, require */

/* global process */
var log; log = function () { return (process.env.IS_DEV) ? console.log.apply(console, arguments) : null; };

var _         = require('lodash');
var SQL       = require('named_sql');
var multiline = require('multiline');

var funcs = {

  'class' : {
    create : function* (app, new_data) {
      var o = new this(app);
      var rows = (yield o.db_insert(new_data)).rows;
      if (rows.length !== 1)
        throw new Error('Unknown error: row length != 1');
      o.data = rows[0];
      return o;
    }
  },

  instance: {

    _init : function (app) {
      this.error       = null;
      this.data        = {};
      this.app         = app;
    },

    clean_the_new_data : function* (new_data) {
      this.new_data = new_data;
      this.clean    = {};
      this.secret   = {};
      var cleaners  = this.constructor.on_data_clean;
      var i = 0;
      var f;

      while (cleaners[i]) {
        f = cleaners[i];
        ++i;
        if (f.constructor.name === 'GeneratorFunction')
          yield f.apply(this);
        else
          f.apply(this);

        if(!this.is_valid())
          i = cleaners.length;
      }

      var fin = {
        clean: this.clean,
        secret: this.secret
      };

      this.secret_data = null;

      if (_.isEmpty(fin.main) && _.isEmpty(fin.extra))
        this.error_msg('all', 'No valid data provided.');

      return fin;
    },

    is_new : function () {
      return !_.has(this.data, this.constructor.primary_key);
    }, // === func is_new


    error_msg : function (col, msg) {
      // === Set error msg:
      if (col) {
        if (this.error)
          throw new Error('Error already set: ' + this.error_msg());
        this.error = {_tags: ['invalid data']};
        this.error[col] = msg;
        return this;
      }

      // === Return an error message for debugging purposes:
      var msgs = _.map(this.error, function (v) { if (_.isString(v)) return v; });
      if (_.isEmpty(msgs))
        msgs = this.error._tags;
      if (_.isEmpty(msgs))
        msgs = ['Unknown error.'];

      return msgs.join(' ');
    },

    clean_the_error : function (err) {
      var this_record = this;
      _.each(
        this.constructor.on_db_error,
        function (f) {
          f.apply(this_record, [err]);
        }
      );
      return this;
    },

    db_insert : function* (new_data) {

      var fin_data    = yield this.clean_the_new_data(new_data);
      var this_record = this;
      var e;

      if (!this.is_valid()) {
        e = new Error(this.error_msg());
        e.megauni_record = this;
        throw e;
      }

      fin_data.idents = {TABLE : this.constructor.table_name};
      var sql = SQL(
        fin_data,
        this.db_insert_sql || multiline(function () {/*
          INSERT INTO :idents.TABLE ( :secret.COLS! )
          VALUES ( :clean.VALS! )
          RETURNING :clean.COLS! ;
        */})
      );

      var db_result;
      try {
        db_result = yield this.app.pg.db.client.query_(sql.sql, sql.vals);
      } catch (db_e) {
        this_record.clean_the_error(db_e);
        if (this_record.is_valid())
          throw db_e;
        e = new Error(this_record.error_msg());
        e.megauni_record = this;
        throw e;
      } // === try/catch


      return db_result;
    }, // === func save

    // === This is to ensure no secret data is
    //     merged into .data.
    //     We get the keys from .clean data,
    //     then get the data from db_data;
    merge: function (db_data) {
      var o = this;
      _.each(this.clean, function (v, k) {
        if (_.has(db_data, k))
          o.data[k] = db_data[k];
      });

      return this;
    },

    db_update : function* () {
      yield this.app.pg.db.query_('');
      throw new Error('not ready');
    } // === func _save_new

  } // === instance

}; // === module.exports


module.exports = function (name) {
  var constructor = function (app) {
    this._init(app, name);
    if (this.init)
      this.init.apply(this, arguments);
  };

  _.extend(constructor.prototype, funcs.instance);
  _.extend(constructor, funcs.class);

  constructor.on_data_clean = [];
  constructor.on_db_error   = [];
  constructor.primary_key   = 'id';
  constructor.table_name    = (name || 'unknown').toLowerCase();
  return constructor;
};

_.extend(module.exports, funcs);

