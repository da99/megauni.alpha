
class Screen_Name

  def update_privacy type
    pid = case type
          when :public
            World_Read_Id
          when :private
            Private_Read_Id
          when :no_one
            Not_Read_Id
          else
            raise "Unknown val: #{type.inspect}"
          end
    row = TABLE.returning.
      where(:id=>id).
      update(:privacy=>pid).
      first

    @data.merge!(row || {})

    self
  end

  def update raw_data
    @new_data = raw_data

    validate :screen_name
    validate(:about).
      set_to_nil_if_empty
    validate(:nick_name).
      set_to_nil_if_empty

    if clean_data[:screen_name]
      clean_data[:display_name] = clean_data[:screen_name]
    end

    row = TABLE.
      returning.
      where(:screen_name=>data[:screen_name]).
      update(clean_data).
      first

    @data.merge!(row || {})

    self
  end # === def update

end # === class Screen_Name update ===





