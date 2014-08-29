
class Customer

  class << self

    def create *args
      r = new
      r.create *args
    end

  end # === class self ===

  def create new_vals, *args
    raise ":create no longer accepts #{new_vals.inspect}" if new_vals.is_a?(Symbol) 

    @new_data = new_vals

    validate(:ip)
    validate(:pass_word).required('Pass phrase is required.')
    validate(:confirm_pass_word).required("Pass phrase confirmation is required.")

    new_vals[:customer] = self
    sn = Screen_Name.create(new_data)

    rec = TABLE.
      returning(:id).
      insert({
        pswd_hash: encode_pass_word(clean_data[:pass_word]),
        id: clean_data[:id]
      }).first

    c = self.class.new rec
    c
  end # === create

end # === class Customer create ===





