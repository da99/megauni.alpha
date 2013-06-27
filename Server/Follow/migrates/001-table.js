
var table = 'Follow';
var m     = module.exports = {};

m.migrate = function (dir, r) {

  if (dir === 'down') {

    r.drop(table);

  } else {

    var sql = 'CREATE TABLE IF NOT EXISTS "' + table + '" ( \
id                serial PRIMARY KEY,            \n\
website_id        int NOT NULL,                  \n\
follower_id       int NOT NULL,                  \n\
last_post_id      int DEFAULT 0 NOT NULL,        \n\
last_updated_at   $now_tz,                       \n\
last_read_at      $now_tz,                       \n\
$created_at       ,                              \n\
$trashed_at       ,                              \n\
CONSTRAINT "'  + table + '_follower"  UNIQUE (website_id, follower_id) \n\
    );';
      r.create(sql, "CREATE INDEX ON \"" + table + "\" (follower_id);");
  }
};
