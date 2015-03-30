

require 'sequel'
require 'datoki'
require 'escape_escape_escape'
DB = Sequel.connect ENV['DATABASE_URL']
DB.cache_schema = false
Datoki.db DB

module Megauni
  
end # === module Megauni


require './Server/Customer/model'
require './Server/Screen_Name/model'
require './Server/Computer/model'
require './Server/Link/model'
