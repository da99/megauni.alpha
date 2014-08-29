
class File_Name

  class << self

    def create raw_name
      name = File_Name.standardize(raw_name)
      begin
      File_Name.new(
        DB[
          %~
            INSERT INTO file_name (file_name)
            VALUES ( :file_name )
            RETURNING *
          ~,
          :file_name=>name
        ].first
      )
      rescue Sequel::UniqueConstraintViolation => e
        raise e unless e.message['unique constraint "file_name_unique_idx"']
        raise File_Name::Invalid.new(
          File_Name.new(:file_name=>name),
          "File name already exists: #{name}"
        )
      end
    end

  end # === class self

end # === class File_Name create ===





