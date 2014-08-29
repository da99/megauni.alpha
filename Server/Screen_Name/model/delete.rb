
class Screen_Name
  class << self

    def delete_by_owner_ids ids
      return if ids.empty?
      TABLE.
        where(TABLE.literal [[ :owner_id, ids]]).
        delete
    end # === def delete

  end # === class self ===
end # === class Screen_Name delete ===





