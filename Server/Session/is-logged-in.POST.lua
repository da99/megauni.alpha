
local cjson_safe = require "cjson.safe"
ngx.say( cjson_safe.encode({x="Sat", y="Fri"}) )


