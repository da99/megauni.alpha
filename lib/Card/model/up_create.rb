

class Computer

  class << self

    def up_create sn, raw_event_name_id, code
      event_name_id = to_event_name_id(raw_event_name_id)
      begin
        row = Computer.read_by_screen_name_id_and_event_name_id(sn.id, event_name_id)
        row.update(:code=>code)
        row
      rescue Computer::Not_Found
        create(sn, event_name_id, code)
      end
    end

  end # === class self ===

end # === class Computer ===



