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
      var rows = yield o.db_insert(new_data);
      if (rows.length !== 1)
        throw new Error('Unknown error: row length != 1');
      o.data = rows[0];
      return o;
    }
  },

  instance: {

    _init : function (app) {
      this.errors     = {};
      this.data       = {};
      this.new_data   = {};
      this.clean_data = {};
      this.app        = app;
    },

    clean : function* (new_data) {
      this.new_data   = new_data;
      this.clean_data = {};
      var cleaners = this.constructor.cleaners;
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

      var fin = _.extend({}, this.clean_data, this.secret_data || {});
      this.secret_data = null;

      if (_.isEmpty(this.clean_data)) {
        this.invalid('all', 'No valid data provided.');
      }
      return fin;
    },

    is_valid : function () {
      return _.isEmpty(this.errors);
    },

    is_new : function () {
      return !_.has(this.data, this.constructor.primary_key);
    }, // === func is_new

    invalid : function (col, msg) {
      if (!this.errors.fields)
        this.errors.fields = {};
      if (!this.errors.tags)
        this.errors.tags = [];
      this.errors.tags.push('invalid data');
      this.errors.fields[col] = msg;
      return this;
    },

    error_msg : function () {
      return (
        (this.errors.fields && _.values(this.errors.fields)) ||
          this.errors.tags ||
          ['Unknown error.']
      ).join(' ');
    },

    clean_error : function (err) {
      var this_record = this;
      _.each(
        this.constructor.on_db_errors,
        function (f) {
          f.apply(this_record, [err]);
        }
      );
      return this;
    },

    db_insert : function* (new_data) {

      var secret      = yield this.clean(new_data);
      var this_record = this;
      var e;

      if (!this.is_valid()) {
        e = new Error(this_record.error_msg());
        e.megauni_record = this;
        throw e;
      }

      var sql = SQL(
        secret,
        {TABLE : this.constructor.table_name},
        this.db_insert_sql || multiline(function () {/*
          INSERT INTO :TABLE ( :COLS! )
          VALUES ( :VALS! )
          RETURNING * ;
        */})
      );

      var result;
      try {
        result = yield this.app.pg.db.client.query_(sql.sql, sql.vals);
      } catch (db_e) {
        this_record.clean_error(db_e);
        if (this_record.is_valid())
          throw db_e;
        e = new Error(this_record.error_msg());
        e.megauni_record = this;
        throw e;
      } // === try/catch

      var keys = _.keys(this.clean_data);
      var rows = (result.rows) ? _.map(result.rows, function (r) {
        return _.reduce(keys, function (memo, k) {
          memo[k] = r[k];
          return memo;
        }, {});
      }) : [];

      return rows;
    }, // === func save

    // === This is to ensure no secret data is
    //     merged into .data.
    //     We get the keys from .clean_data,
    //     then get the data from db_data;
    merge: function (db_data) {
      var o = this;
      _.each(this.clean_data, function (v, k) {
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

  constructor.cleaners     = [];
  constructor.on_db_errors = [];
  constructor.primary_key  = 'id';
  constructor.table_name   = (name || 'unknown').toLowerCase();
  return constructor;
};

_.extend(module.exports, funcs);

