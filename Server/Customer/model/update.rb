
class Customer

  def update raw_data
    @new_data = raw_data

    set = {}

    [:email].each do |key, i|
      if new_data.has_key?(key)
        set[key] = new_data[key]
      end
    end

    r = TABLE.
      returning.
      where(id: data[:id]).
      update(set).
      first

    @data.merge! r
    self
  end # === def update

end # === class Customer update ===





