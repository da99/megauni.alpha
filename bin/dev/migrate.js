#!/usr/bin/env node

// Create databases: okdoki

var PG     = require('okdoki/lib/PG').PG
, SQL      = require('okdoki/lib/SQL').SQL
, Customer = require('okdoki/lib/Customer').Customer
, Chat_Bot = require('okdoki/lib/Chat_Bot').Chat_Bot
, River    = require('okdoki/lib/River').River;

var _      = require('underscore');

var cmd         = (process.argv[2] || 'nothing')
, is_reset_user = cmd === 'reset_with_data'
, is_reset      = cmd === 'reset' || is_reset_user
, is_up         = is_reset || cmd === 'up'
, is_down       = is_reset || cmd === 'down'
, now           = SQL.now
;

if (!is_up && !is_down) {
  console.log('Unknown cmd: ' + process.argv[2]);
  process.exit(1);
}

var ok = PG.new();

function down(names) {
  if (!is_down)
    return true;

  _.each(names, function (n, i) {
    if (n.indexOf('public.') === 0 ) {
      ok.q('DROP TABLE ' + n + '' );
    };
  });
}

function up() {
  if (!is_up)
    return true;

  // ok.q("CREATE EXTENSION IF NOT EXISTS pgcrypto");

  // ok.q(" \
       // CREATE OR REPLACE FUNCTION public.json_get_varchar_array(j text, k text) \
       // RETURNS varchar[] \
       // AS $$    \
       // import json; \
       // d = json.loads(j or '{}'); \
       // return d[k] if k in d else []; \
       // $$ LANGUAGE plpython3u; \
  // ");

  // ok.q(" \
       // CREATE OR REPLACE FUNCTION public.json_get_text_array(j text, k text) \
       // RETURNS text[] \
       // AS $$    \
       // import json; \
       // d = json.loads(j or '{}')[k]; \
       // return  d[k] if k in d else []; \
       // $$ LANGUAGE plpython3u; \
  // ");

   // ok.q(" \
        // CREATE OR REPLACE FUNCTION public.json_get(j text, k text) \
        // RETURNS text \
        // AS $$    \
        // import json; \
        // d = json.loads(j or '{}')[k]; \
        // return  d[k] if k in d else \"\"; \
        // $$ LANGUAGE plpython3u; \
  // ");

     // ok.q(" \
          // CREATE OR REPLACE FUNCTION public.json_merge(o text, n text) \
          // RETURNS text \
          // AS $$    \
          // import json; \
          // oj = json.loads(o or \"{}\");   \
          // nj = json.loads(n or \"{}\");   \
          // f  = dict(list(oj.items()) + list(nj.items())); \
          // return json.dumps(f);         \
          // $$ LANGUAGE plpython3u; \
 // ");

// ok.q(" \
// CREATE OR REPLACE FUNCTION encode_pass_phrase(varchar) \
// RETURNS varchar \
// AS $$ \
// SELECT encode(digest($1, 'sha512'), 'hex') \
// $$ LANGUAGE SQL STRICT IMMUTABLE; \
// ");

ok.q(" \
CREATE TABLE IF NOT EXISTS customers ( \
id varchar(15) PRIMARY KEY, \
created_at timestamp default " + now +",  \
trashed_at timestamp default null,   \
email text,                 \
pass_phrase_hash varchar(150) NOT NULL \
)");

ok.q( " \
CREATE TABLE IF NOT EXISTS screen_names ( \
id                  varchar(15) PRIMARY KEY,   \
owner_id            varchar(15) NOT NULL, \
created_at          timestamp default " + now + ",  \
screen_name         varchar(15) NOT NULL UNIQUE,  \
display_name        varchar(15) NOT NULL UNIQUE,  \
nick_name           varchar(30) default NULL,  \
read_able           varchar(1) default 'N', \
read_able_list      varchar(100) ARRAY,   \
un_read_able_list   varchar(100) ARRAY,   \
about               text default null    \
, trashed_at        timestamp default NULL \
)");

ok.q("CREATE INDEX ON screen_names (owner_id)");

ok.q( " \
CREATE TABLE IF NOT EXISTS bots         ( \
id                  varchar(15) PRIMARY KEY,   \
owner_id            varchar(15) NOT NULL, \
name                varchar(15) NOT NULL UNIQUE,  \
nick_name           varchar(30) default NULL,  \
read_able           varchar(1) default 'W', \
read_able_list      varchar(100) ARRAY,   \
un_read_able_list   varchar(100) ARRAY,   \
url                 text default null    \
, trashed_at        timestamp default NULL \
)");

ok.q( " \
CREATE TABLE IF NOT EXISTS home_pages ( \
owner_id            varchar(15) PRIMARY KEY, \
title               text default null,  \
about               text default null    \
)");

ok.q(" \
 CREATE TABLE IF NOT EXISTS comments ( \
 id                varchar(30) NOT NULL UNIQUE, \
 author_id         varchar(15) NULL, \
 conv_id           varchar(30) NOT NULL UNIQUE, \
 ref_id            varchar(30) NOT NULL UNIQUE, \
 settings          text default null,       \
 details           text default null,       \
 body              text NOT NULL,         \
 created_at        timestamp default " + now + ",  \
 updated_at        timestamp default null, \
 trashed_at        timestamp default null  \
 )");

 ok.q(" \
CREATE TABLE IF NOT EXISTS follows  ( \
id                varchar(30) PRIMARY KEY, \
pub_id            varchar(15) NULL, \
follower_id       varchar(15) NULL, \
settings          text default null,       \
details           text default null,       \
body              text,         \
created_at        timestamp default " + now + ",  \
trashed_at        timestamp default null \
)");

ok.q("CREATE INDEX ON follows (follower_id)");

ok.q(" \
CREATE TABLE IF NOT EXISTS contacts ( \
id                varchar(30) PRIMARY KEY, \
\"from_id\"          varchar(15) NULL, \
\"to_id\"            varchar(15) NULL, \
created_at        timestamp default " + now + ",  \
trashed_at        timestamp default null \
, CONSTRAINT unique_from_id UNIQUE (\"from_id\", \"to_id\") \
)");

ok.q(" \
CREATE UNLOGGED TABLE IF NOT EXISTS online_customers ( \
id                varchar(30) PRIMARY KEY, \
customer_id       varchar(15) NULL, \
screen_name_id    varchar(15) NULL, \
last_seen_at      timestamp default " + now + ",  \
created_at        timestamp default " + now + "  \
, CONSTRAINT unique_customer_id_to_screen_name_id UNIQUE (customer_id, screen_name_id) \
)");

ok.q(" \
CREATE UNLOGGED TABLE IF NOT EXISTS ims ( \
id              varchar(15) PRIMARY KEY,     \
client_id       varchar(15) default NULL,    \
re_id           varchar(15) default NULL,    \
re_client_id    varchar(15) default NULL,    \
\"from_id\"        varchar(15) NOT NULL,        \
\"to_id\"          varchar(15) default 'W',     \
labels          varchar(15) ARRAY,    \
body            text,                 \
created_at      timestamp default " + now + "  \
)");

ok.q(" \
CREATE TABLE IF NOT EXISTS labels   ( \
id                varchar(30) NOT NULL UNIQUE, \
owner_id          varchar(15) NULL, \
label             varchar(40) NULL, \
created_at        timestamp default " + now + ",  \
trashed_at        timestamp default null \
, UNIQUE (owner_id, label) \
)");

ok.q(" \
CREATE TABLE IF NOT EXISTS labelings ( \
id              varchar(30) NOT NULL UNIQUE, \
pub_id          varchar(15) NOT NULL,        \
label_id        varchar(30) NOT NULL, \
created_at      timestamp default " + now + ",  \
trashed_at      timestamp default null   \
, UNIQUE (pub_id, label_id) \
)");

ok.q(" \
CREATE TABLE IF NOT EXISTS posts ( \
  id                  varchar(30) PRIMARY KEY,     \
  pub_id              varchar(30) NOT NULL,        \
  re_id               varchar(30) NOT NULL,        \
  author_id           varchar(30) NOT NULL,        \
  section_id          smallint NOT NULL,           \
  title               varchar(100) default null,   \
  body                text,                        \
  extra               text default '{}',           \
  read_able           varchar(1) default 'W',      \
  read_able_list      varchar(100) ARRAY,          \
  un_read_able_list   varchar(100) ARRAY,          \
  created_at          timestamp default " + now + ",  \
  trashed_at          timestamp default null       \
)");

ok.q(" CREATE INDEX ON posts (created_at DESC); ");
}

function create(meta) {
  console.log('Finished migrating the main db.');
  if (!is_reset_user) {
    return;
  }

  var p     = "pass phrase";
  var report = function (j) {
    console.log('Finished ' + j.group + ' ' + j.id);
  };

  var c_opts = {pass_phrase: p, confirm_pass_phrase: p, ip: '000.000.00'};

  var r = River.new();
  r.for_each_finish(report);
  r.job('create:', 'go99', function (j) {
    Customer.create(_.extend({screen_name: j.id}, c_opts), (j));
  });

  r.job('create:', 'dos', function (j) {
    Customer.create(_.extend({screen_name: j.id}, c_opts), (j));
  });

  r.job('create bot:', '404', function (j) {
    var c = j.river.reply_for('create:', 'go99');
    Chat_Bot.create({owner_id: c.data.id, url: "https://okdoki-bot.herokuapp.com/test/404/404", name: j.id}, (j));
  });

  r.job('create bot:', 'ok', function (j) {
    var c = j.river.reply_for('create:', 'go99');
    Chat_Bot.create({owner_id: c.data.id, url: "https://okdoki-bot.herokuapp.com/test/ok", name: j.id}, (j));
  });

  r.job('create bot:', 'im', function (j) {
    var c = j.river.reply_for('create:', 'dos');
    Chat_Bot.create({owner_id: c.data.id, url: "https://okdoki-bot.herokuapp.com/test/im", name: j.id}, (j));
  });

  r.job('create bot:', 'not_json', function (j) {
    var c = j.river.reply_for('create:', 'dos');
    Chat_Bot.create({owner_id: c.data.id, url: "https://okdoki-bot.herokuapp.com/test/not_json", name: j.id}, (j));
  });

  r.run();

};

PG.show_tables(function (tables) {
  down(tables);
  up();
  ok.on_finish(create);
  ok.run();
});


// ==========================================================================================
// console.log('Process id: ' + process.pid);




