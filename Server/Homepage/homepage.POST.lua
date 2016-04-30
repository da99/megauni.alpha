
local cjson_safe = require "cjson.safe"
local MariaDB = require "./Server/Megauni/mariadb.lua"

local ok, DB = MariaDB.connect()

if not ok  then
  ngx.say( cjson_sage.encode( DB ) )
  return
end

DB:close()
ngx.say( cjson_safe.encode( {ok = true, msg = "Connection ok" } ) )


