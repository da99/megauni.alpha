
class File_Name

  class << self

    def read raw_name
      name = File_Name.standardize(raw_name)

      File_Name.new(
        TABLE.
        returning.
        where(:file_name=>name).
        first, "File name, \"#{name}\", not found."
      )
    end

  end # === class self ===

  def id
    data[:id]
  end

  def file_name
    data[:file_name]
  end

end # === class File_Name model ===





