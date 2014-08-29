
class File_Name

  class << self

    def read_create raw_name
      begin
        File_Name.read(raw_name)
      rescue File_Name::Not_Found
        File_Name.create(raw_name)
      end
    end

  end # === class self

end # === class File_Name read_create ===





