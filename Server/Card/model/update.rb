
class Computer

  def update owner, raw
    cols = [:code, :class_id]
    data = validate_class_id(validate_class_name validate_code(raw)).select { |k,v|
      cols.include?(k)
    }

    @data.merge!(
      TABLE.
      returning.
      where(:id=>id).
      update(data).
      first || {}
    )

    self
  end # === def update

end # === class Computer ===





