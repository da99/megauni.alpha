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
      yield o.db_insert(new_data);
      return o;
    }
  },

  instance: {

    _init : function (app, name) {
      this.errors     = {};
      this.data       = {};
      this.new_data   = {};
      this.clean_data = {};
      this.app        = app;
      this.table_name = (name || 'unknown').toLowerCase();
    },

    clean : function* (new_data) {
      this.new_data   = new_data;
      this.clean_data = {};
      var i = 0;
      var f;

      while (this.constructor.cleaners[i]) {
        f = this.cleaners[i];
        ++i;
        if (f.constructor.name === 'GeneratorFunction')
          yield f.apply(this);
        else
          f.apply(this);

        if(!this.is_valid())
          i = this.cleaners.length;
      }

      var fin = _.extend(this.clean_data, this.secret_data || {});
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
      return _.has(this.data, 'id');
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

    db_insert : function* (new_data, sql) {

      this.new_data = new_data;
      var secret = yield this.clean();

      if (!this.is_valid()) {
        var e = new Error(_.values(this.errors.fields).join(' '));
        e.megauni_record = this;
        throw e;
      }

      sql = sql || SQL(
        secret,
        {TABLE : this.table_name},
        multiline(function () {/*
          INSERT INTO :TABLE ( :COLS )
          VALUES ( :VALS )
          RETURNING * ;
        */})
      );

      var result = yield this.app.pg.db.client.query_(sql.sql, sql.vals);
      this.merge(result.rows[0] || {});

      return this;
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
  constructor.cleaners = [];
  _.extend(constructor, funcs.class);
  return constructor;
};

