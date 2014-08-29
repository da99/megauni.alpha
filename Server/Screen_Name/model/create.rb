
class Screen_Name

  class << self

    def create *args
      r = new
      r.create *args
    end

  end # === class self ===

  #
  # Possible args:
  #   hash
  #   customer, 'screen_name'
  #
  def create *args
    raise ":create no longer accepts #{args.first.inspect}" if args.first.is_a?(Symbol)

    raw_data = if args.size == 2 && args.first.is_a?(Customer) && args.last.is_a?(String)
                 {:customer=>args.first, :screen_name=>args.last}
               else
                 args.shift
               end

    # === Validate the data.
    @new_data = raw_data
    @clean_data = {}

    is_new_owner = !new_data[:customer].data[:id]

    validate(:screen_name).required

    validate(:class_id)

    validate(:read_able).
      one_of_these(['@W', '@P', '@N'], "Allowed values: @W (world) @P (private) @N (no one)")

    insert_data = {
       :owner_id     => is_new_owner ? 0 : new_data[:customer].data[:id],
       :screen_name  => clean_data[:screen_name],
       :display_name => clean_data[:screen_name]
    }

    begin
      new_record = TABLE.returning.insert(insert_data).first
    rescue Sequel::UniqueConstraintViolation => e
      raise e unless e.message['"screen_name_unique_idx"']
      raise self.class::Invalid.new(self, "Screen name already taken: #{clean_data[:screen_name]}")
    end

    me = self.class.new(new_record)
    if is_new_owner
      me.data[:owner_id] = me.id
      new_data[:customer].clean_data[:id] = me.id
    end

    return me unless is_new_owner

    # ==== This is a new customer
    # ==== so we must use the screen name id
    # ==== as the owner_id because customer record
    # ==== has not been created.
    new_row = TABLE.returning.where(:id=>me.id).update(:owner_id=>me.id).first
    new_data[:customer].data[:id] = me.id
    new_data[:customer].clear_cache

    self.class.new(me.data.merge new_row)
  end # === def create

end # === class Screen_Name create ===





