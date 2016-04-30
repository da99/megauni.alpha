
local Megauni_DB = {}

function Megauni_DB.connect ()

  local mysql = require "resty.mysql"
  local db, err = mysql:new()

  if not db then
    return false, {
      ok = false,
      error_type = "db-server-conn",
      error_suggestion = "try-again-later"
    }
  end

  db:set_timeout(1000) -- 1 sec

  local ok, err, errno, sqlstate = db:connect{
    host            = "127.0.0.1",
    port            = 3306,
    database        = os.getenv("MARIADB_DB"),
    user            = os.getenv("MARIADB_USER"),
    password        = os.getenv("MARIADB_PSWD"),
    max_packet_size = 1024 * 1024
  }

  if not ok then
    return false, {
      ok = false,
      error_type = "db-conn",
      error_suggestion = "try-again-later"
    }
  end

  return true, db

end -- function connect

return Megauni_DB

