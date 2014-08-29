"use strict";

$(function () {
  var c = Box.read('Customer_Screen_Names');
  if (c)
    Customer.log_in(c.split(/\s+/));
});

var Customer = {

  _sns                    : [],
  is_stranger             : true,
  is_customer             : false,
  is_owner_of_screen_name : false,
  has_one_life            : false,

  log_in : function (arr) {
    this.screen_names(arr);
  },

  fav_screen_name : function (n) {
    if (n)
      this._fav = n;
    return this._fav;
  },

  screen_names : function (arr) {

    if (arr) {
      this._sns         = arr;
      this.is_stranger  = false;
      this.is_customer  = !this.is_stranger;
      this.has_one_life = this._sns.length === 1;

      this.fav_screen_name( _.last(arr) );

      this.is_owner_of_screen_name = Screen_Name.is_found && _.detect(arr, function (n) {
        return Screen_Name.screen_name().toUpperCase() == n.toUpperCase() ;
      });
    }

    return this._sns;
  }

};
