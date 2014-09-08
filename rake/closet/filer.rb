class Filer < Thor
    include Thor::Sandbox::CoreFuncs

    desc :rename_ext, "Rename file extension of files in a directory." 
    def rename_ext

        dir = ask("Enter directory: #{Pow()}/").to_s.sub(/^\/{1,}/, '').strip
        raise ArgumentError, "Empty dir name not allowed." if dir.empty?

        oDir = Pow(dir)
        raise ArgumentError, "Dir does not exist: #{oDir}" if !oDir.directory?

        ext = get_and_validate_ext("Enter extension:")
        new_ext = get_and_validate_ext("Enter new extention:")

        oDir.each { |file|
            ext_reg = /\.#{ext}\z/
            if file.file? && file.to_s =~ ext_reg
                old_name = file.to_s
                new_name = file.to_s.sub(/\.#{ext}\z/, ".#{new_ext}")
                if Pow(new_name).exists?
                    shout "New file already exists: #{new_name}"
                else
                    shout capture_all("mv %s %s" , old_name , new_name ).to_s
                end
            else
                whisper "Skipping non-file: #{file}" if !file.file?
                whisper "Skipping non-#{ext}: #{file}" if file.to_s !~ ext_reg
            end
        }
        whisper "Done." 
    end


  private # ==============================================================

  def get_and_validate_ext(q)
      ext = ask(q).to_s.sub(/^\.{1,}/, '').strip
      raise ArgumentError, "Invalid file extension: #{ext}" if ext.empty?
      ext
  end  
end

