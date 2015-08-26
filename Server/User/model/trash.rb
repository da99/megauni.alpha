
class Customer

  TRASH_KEY = :id

  class << self

    def empty_trash
      rows = super
      ids = rows.map { |r| r[:id] }
      Screen_Name.delete_by_owner_ids ids
    end # === def delete_trashed

  end # === class self ===

  def generate_trash_msg name_or_row

    if name_or_row[:screen_name]
      name = name_or_row[:screen_name]
      r    = name_or_row
    else
      name = name_or_row
      r    = screen_name_row(name)
    end

    if !r[:trashed_at]

      r[:trash_msg] = nil

    else
      durs          = Duration(Date(Date.now()), reltime.parse(r[:trashed_at], "48 hours"))
      is_past       = durs.days < 1 && durs.hour < 1 && durs.minute < 1
      r[:trash_msg] = "Screen name, #{r[:screen_name]}"

      if is_past
        r[:trash_msg] += ", has been deleted. There is no undo."
      else
        r[:trash_msg] += ", has been put in trash."
        r[:trash_msg] += " You have #{human_durs(durs)} from now to change your mind before it gets completely deleted."
      end

    end

    r[:trash_msg]
  end # === def generate_trash_msg ===

end # === class Customer trash ===





