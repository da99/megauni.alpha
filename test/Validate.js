
var _ = require('underscore')
, assert = require('assert')
, Validate = require('okdoki/lib/Validate').Validate
;


describe( 'Validate', function () {

  describe( '.validate', function () {

    it( 'trims values by default', function () {
      var o = {new_data: {name: " name_1 "}};
      Validate.new('test 1', function (v) {
        v.define('name', function (v) { });
      }).validate(o);
      assert.deepEqual(o.sanitized_data, {name: "name_1"});
    });

    it( 'returns true if valid', function () {
      var o = {new_data: {name: " name_1 "}};
      var result = Validate.new('test 1', function (v) {
        v.define('name', function (v) { });
      }).validate(o);
      assert.equal(result, true);
    });

    it( 'returns false if invalid', function () {
      var o = {new_data: {name: " name_1 "}};
      var result = Validate.new('test 1', function (v) {
        v.define('name', function (v) { v.at_least(100); });
      }).validate(o);
      assert.equal(result, false);
    });

    it( 'calls River.invalid(msg)', function (done) {
      var o = {new_data: {name: " name_1 "}};
      var result = Validate.new('test 1', function (v) {
        v.define('name', function (v) { v.at_least(100); });
      }).validate(o, {invalid: function (msg) {
        assert.equal(msg, "name must be at least: 100");
        done();
      }});
    });

    it( 'does not validate non-existent keys', function (done) {
      var o = {new_data: {name: " name_1 "}};
      var result = Validate.new('test 1', function (v) {
        v.define('name', function (v) { v.at_least(2); });
        v.define('about', function (v) { v.is_null_if_empty(); });
      }).validate(o, {invalid: function (msg) {
        throw new Error(msg);
      }, finish: function (v) {
        assert.deepEqual(o.sanitized_data, {name: 'name_1'});
        done();
      }});
    });

  }); // === describe

  describe( '.at_least', function () {

    it( 'sets error msg if less than min', function () {
      var o = {new_data: {name: "123"}};
      Validate.new('at_least', function (v) {
        v.define('name', function (v) { v.at_least(5); });
      }).validate(o);
      assert.equal(o.errors, 'name must be at least: 5');
    });
  }); // === describe

  describe( '.between', function () {
    it( 'sets error msg if: length < min', function () {
      var o = {new_data: {name: "123"}};
      Validate.new('between', function (v) {
        v.define('name', function (v) { v.between(5,10); });
      }).validate(o);
      assert.equal(o.errors, 'name must be between: 5 and 10');
    });

    it( 'sets error msg if: length > max', function () {
      var o = {new_data: {name: "1234567890123"}};
      Validate.new('between', function (v) {
        v.define('name', function (v) { v.between(5,10); });
      }).validate(o);
      assert.equal(o.errors, 'name must be between: 5 and 10');
    });
  }); // === describe

  describe( '.at_least_2_words', function () {

    it( 'sets error if there is no space', function () {
      var o = {new_data: {name: "1234567890123"}};
      Validate.new('at_least_2_words', function (v) {
        v.define('name', function (v) { v.at_least_2_words(); });
      }).validate(o);
      assert.equal(o.errors, 'name must be two words or more.');
    });
  }); // === describe

  describe( '.equals', function () {

    it( 'sets error if value does not equal', function () {
      var o = {new_data: {name: "same"}};
      Validate.new('equals', function (v) {
        v.define('name', function (v) { v.equals('sa,e'); });
      }).validate(o);
      assert.equal(o.errors, 'name must equal: sa,e');
    });
  }); // === describe

  describe( '.not_empty', function () {
    it( 'sets error if value is null', function () {
      var o = {new_data: {name: null}};
      Validate.new('equals', function (v) {
        v.define('name', function (v) { v.not_empty(); });
      }).validate(o);
      assert.equal(o.errors, 'name must not be empty.');
    });

    it( 'sets error if value is undefined', function () {
      var o = {new_data: {name: undefined}};
      Validate.new('equals', function (v) {
        v.define('name', function (v) { v.not_empty(); });
      }).validate(o);
      assert.equal(o.errors, 'name must not be empty.');
    });

    it( 'sets error if value is an empty string', function () {
      var o = {new_data: {name: ' '}};
      Validate.new('equals', function (v) {
        v.define('name', function (v) { v.not_empty(); });
      }).validate(o);
      assert.equal(o.errors, 'name must not be empty.');
    });

    it( 'sets error if value is an empty array', function () {
      var o = {new_data: {name: []}};
      Validate.new('equals', function (v) {
        v.define('name', function (v) { v.not_empty(); });
      }).validate(o);
      assert.equal(o.errors, 'name must not be empty.');
    });
  }); // === describe

  describe( '.length_gte', function () {

    it( 'sets error if length is less than min', function () {
      var o = {new_data: {name: "abcdef"}};
      Validate.new('length_gte', function (v) {
        v.define('name', function (v) { v.length_gte(10); });
      }).validate(o);
      assert.equal(o.errors, 'Length of name must be greater or equal to: 10');
    });
  }); // === describe

  describe( '.match', function () {
    it( 'sets error if string does not matche regex', function () {
      var o = {new_data: {name: "ab"}};
      Validate.new('.match', function (v) {
        v.define('name', function (v) { v.match(/ABC/gi); });
      }).validate(o);
      assert.equal(o.errors, 'name must match: /ABC/gi');
    });
  }); // === describe

  describe( '.not_match', function () {
    it( 'sets error if string matches regex', function () {
      var o = {new_data: {name: "abcdef"}};
      Validate.new('.not_match', function (v) {
        v.define('name', function (v) { v.not_match(/ABC/gi); });
      }).validate(o);
      assert.equal(o.errors, 'name must not match: /ABC/gi');
    });
  }); // === describe

  describe( '.found_in', function () {
    it( 'sets error if value not found in array', function () {
      var o = {new_data: {name: "pet"}};
      Validate.new('.found_in', function (v) {
        v.define('name', function (v) { v.found_in(['a', 'b']); });
      }).validate(o);
      assert.equal(o.errors, 'name must be one of the following: a, b');
    });
  }); // === describe

  describe( '.contains_only', function () {
    it( 'sets error if array contains a disallowed value', function () {
      var o = {new_data: {name: ['human', "pet"]}};
      Validate.new('.contains_only', function (v) {
        v.define('name', function (v) { v.contains_only(['human']); });
      }).validate(o);
      assert.equal(o.errors, 'name must only contain the following: human');
    });
  }); // === describe

}); // === describe












