
module HTML_ASSETS

    
    def it_has_assets( page_path, *asset_types )
        asset_types_as_str = asset_types.empty? ? 'CSS and JS' : asset_types.map {|m| m.to_s.upcase}.join(' and ')
        it "has #{asset_types_as_str} assets" do
            get_assets( page_path, *asset_types )
        end
    end
    
    def get_assets( page_path, *asset_types )
        valid_types = [:css, :js]
        asset_types += [:css, :js] if asset_types.empty?
        invalid_types = asset_types - valid_types
        raise "INVALID OPTIONS: #{invalid_opts.inspect}" if !invalid_types.empty?
        
        get page_path
        
        css_files = response.body.scan( /href\=\"(.+\.css[^\"]{0,})\"/ ).flatten
        js_files = response.body.scan( /src\=\"(.+\.js[^\"]{0,})\"/ ).flatten
        
        raise "CSS file not found." if css_files.empty? && asset_types.include?(:css)
        raise "Unexpected CSS files found." if !css_files.empty? && !asset_types.include?(:css)
        
        raise "JS files not found." if js_files.empty? && asset_types.include?(:js)
        raise "Unexpected JS files found." if !js_files.empty? && !asset_types.include?(:js)
        
        
        puts "\n"
        css_files.each { |new_path|
            puts '   ' +new_path
            get new_path
            response.should.be.ok
            response["Content-Type"].should.be == 'text/css'
        }   
        

        js_files.each { |new_path|
            puts '   ' + new_path
            get new_path
            response.should.be.ok
            response["Content-Type"].should.be == "application/javascript"
        }        
    end
end

class Bacon::Context
  include HTML_ASSETS
end

