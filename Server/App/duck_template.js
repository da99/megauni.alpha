

var table = ;
var m     = module.exports = {};

var _     = require('underscore');
var River = require('da_river').River;

m.migrate = function (dir, r) {

  if (dir === 'down') {

    r.drop(table);

  } else {

    var sql = 'CREATE TABLE "@T" (                              \n\
    $created_at    ,                                            \n\
    $updated_at    ,                                            \n\
    $trashed_at                                                 \n\
    );'.replace(/@T/g, table);
    r.create(sql,
             'CREATE INDEX "@T_" ON "@T" ()'.replace(/@T/g, table)
            );

  }
};
