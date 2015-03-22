
# Parameters: 
#   dir - Relative to the current working directory of the app.
#   allow_only  - Optional. It is an array of ruby file names without 
# an extension.
def require_these( dir, allow_only=nil )
  if allow_only
    allow_only.uniq.each { |file_name| 
      require File.join(dir, file_name.to_s) 
    }
  else
    Dir[ File.join(dir, '*.rb') ].each { |file_name_rb| 
      # Replace 'models/resty.rb' to 'models/resty'
      file_name = file_name_rb.sub(/\.rb\z/, '')  
      require file_name
    }
  end
end

def require_file relative_path
  require File.expand_path(relative_path)
end
