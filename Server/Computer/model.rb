
require './Server/Okdoki/model'
require './Server/Okdoki/Vador'
require './Server/Okdoki/Escape_All'
require 'www_applet'

require_crud :Computer

class Computer

  include Okdoki::Model

  EVENT_NAMES = {
    1 => "ON VIEW PROFILE"
  }

  # =====================================================
  # Settings
  # =====================================================

  Table_Name = :computer
  TABLE = DB[Table_Name]

  # =====================================================
  # Class
  # =====================================================

  class << self
  end # === class self ===

  # =====================================================
  # Instance
  # =====================================================

  def validate_code hash
    if !hash.has_key?(:code)
      raise Invalid.new(self, "Code is required.")
    end
    hash[:code] = MultiJson.dump(Okdoki::Escape_All.escape MultiJson.load(hash[:code]))
    hash
  end

  def validate_path hash
    if !hash.has_key?(:path)
      raise Invalid.new(self, "Path is required.")
    end
    raw = hash[:path].strip.downcase

    if raw.length > 0 && raw !~ /\A[a-z0-9\_\-\/]+\*?\Z/
      raise Invalid.new(self, "Invalid chars in path: #{raw}")
    end

    if raw == "/*"
      raise Invalid.new(self, "Not allowed, /*, because it will grab all pages.")
    end

    hash[:path] = raw
    hash
  end

end # === class Computer ===






