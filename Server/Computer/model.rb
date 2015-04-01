
class Computer

  include Datoki

  WORLD     = 1
  PROTECTED = 2
  PRIVATE   = 3

  EVENT_NAMES = {
    1 => "ON VIEW PROFILE"
  }

  field(:id) {
    primary_key
  }

  field(:owner_id) {
    integer
  }

  field(:privacy) {
    smallint 1, 3
    matches do |r, v|
      if ![WORLD, PROTECTED, PRIVATE].include?(v)
        r.fail! "Allowed values: 1 (world) 2 (protected) 3 (private, no one) 4 (me and the author, eg comment)"
      end
      true
    end
  }
  field(:code) {
    string_ish 1, 1000
    set_to { |r, val|
      if val.is_a?(Hash)
        Escape_Escape_Escape.json_encode val
      else
        Escape_Escape_Escape.json_encode(:code=>val)
      end
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
    clean :privacy
  end

  def update
    clean :privacy
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

  def posted_to sn, by
    Link.create(
      owner_id: by.data[:owner_id],
      type_id: Link::POST_TO_SCREEN_NAME,
      asker_id: id,
      giver_id: sn.id
    )
  end

end # === class Computer ===






