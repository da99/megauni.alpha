

class Sass < Thor
  include Thor::Sandbox::CoreFuncs  
  desc :compile, "Turn all SASS files to CSS."
  def compile
    return nil if  !Pow('views/skins/jinx/sass').exists?
    results = capture_all(
      "compass -r ninesixty -f 960 --sass-dir views/skins/jinx/sass --css-dir public/skins/jinx/css -s compressed"
    )
    clean_results   = results.split("\n").reject { |line| 
                                                            line =~ /^unchanged\ / ||
                                                            line.strip =~ /^(compile|exists|create)/
                                                         }.join("\n")
    
    raise( clean_results ) if results['WARNING:'] || results['Error']
    invoke :delete_sass_cache
    say "Compiled SASS to CSS"
    
  end # === def
  
  desc :delete, "Delete compiled CSS files.." 
  def delete
    return nil if !Pow('views/skins/jinx/sass').exists?
    Pow('views/skins/jinx/sass').each { |f| 
      if f.file? && f.to_s =~ /\.sass\z/ 
        css_file = Pow( 'public/skins/jinx/css', File.basename(f.to_s).sub( /\.sass\z/, '') + '.css' )
        css_file.delete if css_file.exists? 
      end
    }
    invoke(:delete_sass_cache)
    say "Deleted compiled CSS files."
  end
  
  desc :delete_sass_cache, "Delete .sass-cache dir."
  def delete_sass_cache
    if Pow('.sass-cache').directory?
      results = capture_all('rm -r .sass-cache')
      say results if !results.empty?
    end
  end
  
end # === class


