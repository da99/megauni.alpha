"use strict";
/* jshint -W079, esnext: true, undef: true, unused: true */
/* global require, module  */
var log; log = require('../Megauni/console').log;

const _           = require('lodash');
const Model       = require('../Megauni/model');

const WORLD     = 1;
const PROTECTED = 2;
const PRIVATE   = 3;

const MIN_CODE_BYTES = 1;
const MAX_CODE_BYTES = 2500;

class Card extends Model {
} // === class Card

Card.on(
  'data_clean',

  function () { // === clean :privacy
    let KEY = 'privacy';
    if (!this.new_data.hasOwnProperty(KEY))
      return;
    let val = parseInt(this.new_data[KEY]);
    if (!_.contains([WORLD, PROTECTED, PRIVATE], val))
      return this.error_msg(KEY,  "Allowed values: 1 (world) 2 (protected) 3 (private, no one) 4 (me and the author, eg comment)");

    this.clean[KEY] = val;
  },

  function () { // === clean :code
    let KEY = 'code';
    if (!this.is_new() || !(this.new_data.hasOwnProperty(KEY)))
      return;
    let val = this.new_data[KEY].toString();

    if (val.length < MIN_CODE_BYTES)
      return this.error_msg(KEY, 'No value set for :code.');
    if (val.length > MAX_CODE_BYTES)
      return this.error_msg(KEY, 'Too large. Use less code.');

    try {
      this.clean_data[KEY] = JSON.stringify(val);
    } catch (e) {
      this.error_msg(KEY, 'Invalid format for :code.');
    }
  }

); // === on data_clean




// const validate_path = function (hash) {
    // if !hash.has_key?(:path)
      // raise Invalid.new(self, "Path is required.")
    // end
    // raw = hash[:path].strip.downcase

    // if raw.length > 0 && raw !~ /\A[a-z0-9\_\-\/]+\*?\Z/
      // raise Invalid.new(self, "Invalid chars in path: #{raw}")
    // end

    // if raw == "/*"
      // raise Invalid.new(self, "Not allowed, /*, because it will grab all pages.")
    // end

    // hash[:path] = raw
    // hash
// }; // === validate_path

// const posted_to = function (sn, by) {
    // Link.create(
      // owner_id: by.data[:owner_id],
      // type_id: Link::POST_TO_SCREEN_NAME,
      // asker_id: id,
      // giver_id: sn.id
    // )
// };

// const is type = function () {
    // new_computer = Computer.update(
      // id: id,
      // privacy: self.class.const_get(type.to_s.upcase.to_sym)
    // )
    // @data = @data.merge new_computer.data
    // self
// }


module.exports = Card;




