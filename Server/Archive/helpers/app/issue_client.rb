

require 'rest_client'

class IssueClient

    def self.required_cols
      @required_cols ||= [ :app_name, 
                      :title,
                      :body, 
                      :environment, 
                      :path_info,
                      :user_agent, 
                      :ip_address ]
    end 
    def self.data_template
      required_cols.inject({}) { |m, k|
        m[k] = ''
        m
      }
    end
    
    def self.create(env, environ, *args)
      case args.size
        when 1
          e, title, body = args
        else
          title, body, e = args
      end

      params = if env['the.app']
                 env['the.app'].request.params
               else
                 'No params.'
               end
      query_string = (env['QUERY_STRING'].to_s.strip.empty? ? 
                      '' : 
                      ' (with query string)' 
                     )
      path_info    = env['PATH_INFO'].to_s + query_string

      data = data_template.merge( 
       {:path_info  => path_info,
        :api_key    => 'luv.4all.29bal--w0l3mg930--3',
        :app_name   => 'Mega Uni', 
        :title      => (title || e.message),
        :body       => (body.inspect + "\n\nParams: " + params.inspect + "\n\nKeys: " + env.keys.join("\n") + "\n\n" + e.backtrace.reject {|b| b['mnt/.gems/gems'] || b['lib/ruby/gems'] }.join("\n")), 
        :environment => environ.to_s ,
        :user_agent => env['HTTP_USER_AGENT'],
        :ip_address => env['REMOTE_ADDR'] || 'MISSING'
      })

      case environ.to_sym
        when :production
          RestClient.post( 'https://miniuni.heroku.com/error', data)
        when :development, :test
          # error_file   = File.expand_path("~/Desktop/MEGAUNI_ERRORS_#{environ}.txt")
          # orig_content = File.file?(error_file) && environ.to_sym != :test ? 
          #                 File.read(error_file) : 
          #                 ''
          # error_file.create { |f|
          #   f.puts( data.inspect + "\n\n" + orig_content )
          # }
        else
          raise ArgumentError, "Unknown environment: #{environ.inspect}"
      end
 
    end    
end


