
class Computer

  include Datoki

  EVENT_NAMES = {
    1 => "ON VIEW PROFILE"
  }

  field(:owner_id) {
    integer
  }

  field(:code) {
    string_ish 1, 1000
    set_to { |r, val|
      Escape_Escape_Escape.json_encode val
    }
  }

  # =====================================================
  # Settings
  # =====================================================

  # =====================================================
  # Class
  # =====================================================

  class << self
  end # === class self ===

  # =====================================================
  # Instance
  # =====================================================

  def create
    clean! :owner_id, :code
  end

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






