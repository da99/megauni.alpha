"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global module, require */

/* global process */
var log; log = function (...args) { return (process.env.IS_DEV) ? console.log.apply(console, args) : null; };

var _         = require('lodash');
var SQL       = require('named_sql');

class Invalid_Data extends Error {

  constructor (record, msg) {
    super(msg || record.error_msg());
    this.megauni = {
      record : record
    };
  }

} // === class Invalid_Data

class Model {

  static primary_key(name) {
    if (name)
      this._primary_key = name;
    return this._primary_key || 'id';
  }

  static table_name() {
     return (this.name || 'unknown').toLowerCase();
  }

  static on(raw_name, ...args) {
    var name = `_#{raw_name}`;
    var f;
    if (!this.hasOwnProperty(name))
      f = this[name] = [];
    if (args.length)
      f = this[name] = f.concat(args);
    return f;
  }

  static * create(app, new_data) {
    let o = new this(app);
    let rows = (yield o.db_insert(new_data)).rows;
    if (rows.length !== 1)
      throw new Error('Unknown error: row length != 1');
    o.data = rows[0];
    return o;
  }

  constructor (app) {
    this.error       = null;
    this.data        = {};
    this.app         = app;
  }


  * clean_the_new_data (new_data) {
    this.new_data = new_data;
    this.clean    = {};
    this.secret   = {};
    let cleaners  = this.constructor.on_data_clean;

    for (let f of cleaners) {
      if (f.constructor.name === 'GeneratorFunction')
        yield f.apply(this);
      else
        f.apply(this);

      if (!this.is_valid())
        break;
    }

    let fin = {
      clean: this.clean,
      secret: this.secret
    };

    this.secret = null;

    if (_.isEmpty(fin.clean) && _.isEmpty(fin.secret))
      this.error_msg('all', 'No valid data provided.');

    return fin;
  } // === func clean_the_new_data

  is_new () {
    return !_.has(this.data, this.constructor.primary_key);
  } // === func is_new


  error_msg (col, msg) {
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
  }

  clean_the_error (err) {
    var this_record = this;
    _.each(
      this.constructor.on_db_error,
      function (f) {
        f.apply(this_record, [err]);
      }
    );
    return this;
  }

  * db_insert (new_data) {

    var fin_data = yield this.clean_the_new_data(new_data);

    if (!this.is_valid()) {
      throw new Invalid_Data(this);
    }

    fin_data.idents = {TABLE : this.constructor.table_name};
    var sql = SQL(
      fin_data,
      this.db_insert_sql || `
      INSERT INTO :idents.TABLE ( :secret.COLS! )
      VALUES ( :clean.VALS! )
      RETURNING :clean.COLS! ;
      `
    );

    var db_result;
    try {
      db_result = yield this.app.pg.db.client.query_(sql.sql, sql.vals);
    } catch (db_e) {
      this.clean_the_error(db_e);
      if (this.is_valid())
        throw db_e;
      throw new Invalid_Data(this);
    } // === try/catch


    return db_result;
  } // === func save

  // === This is to ensure no secret data is
  //     merged into .data.
  //     We get the keys from .clean data,
  //     then get the data from db_data;
  merge (db_data) {
    var o = this;
    _.each(this.clean, function (v, k) {
      if (_.has(db_data, k))
        o.data[k] = db_data[k];
    });

    return this;
  }

  * db_update () {
    yield this.app.pg.db.query_('');
    throw new Error('not ready');
  } // === func _save_new

} // === class Model


module.exports = Model;


