
require './Server/Okdoki/model'

require_crud :File_Name

class File_Name

  include Okdoki::Model


  # =====================================================
  # Settings
  # =====================================================

  Table_Name    = :file_name
  TABLE         = DB[Table_Name]
  VALID         = /\A[a-z0-9\-\_]+\Z/
  Invalid_Chars = Class.new(StandardError)

  # =====================================================
  # Class
  # =====================================================

  class << self

    def standardize raw
      clean = raw.strip.downcase
      raise Invalid.new(clean, "Invalid chars in: #{clean}") unless clean[VALID]
      clean
    end

  end # === class self ===

  # =====================================================
  # Instance
  # =====================================================


end # === class File_Name ===





