

require 'sequel'
require 'datoki'
require 'escape_escape_escape'
require 'i_dig_sql'

DB = Sequel.connect ENV['DATABASE_URL']
Datoki.db DB

module Megauni
end # === module Megauni


require './Server/Customer/model'
require './Server/Screen_Name/model'
require './Server/Computer/model'
require './Server/Link/model'
