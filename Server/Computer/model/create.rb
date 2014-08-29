
class Computer

  class << self

    def create owner, raw_code
      applet = WWW_Applet.new(raw_code)
      path = applet.extract_first("path").last
      new.create(
        :owner_id => owner.id,
        :path     => path,
        :code     => applet.code
      )
    end

  end # === class self ===

  def create data
    data = validate_path validate_code(data)

    row = TABLE.
      returning.
      insert(data).
      first

    Computer.new(row)
  end # === def create

end # === class Computer create ===





