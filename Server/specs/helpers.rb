
require 'ostruct'
require 'Bacon_Colored'
require 'pry'

require './Server/Megauni/model'
require './Server/Screen_Name/specs/helpers'

DB.cache_schema = false

PERM        = 301
TEMP        = 302
EXAMPLE_URL = 'http://www.mises.org/'

module Bacon
  class Context

    alias_method :run_requirement_without_reset_my_cache, :run_requirement
    def run_req_and_reset_my_cache *args
      @my_cache = {:context => self}
      @my_cache.default_proc = lambda { |h, k|
        fail ArgumentError, "Unknown key: #{k.inspect}"
      }
      run_requirement_without_reset_my_cache *args
    end
    alias_method :run_requirement, :run_req_and_reset_my_cache

    def WORLD!
      @my_cache[:default_privacy] = :WORLD
    end

    %w{ sn friend meanie aud STRANGER }.each { |name|
      eval <<-EOF, nil, __FILE__, __LINE__ + 1
      def #{name} *args
        unless @my_cache.has_key?(:#{name})
          @my_cache[:#{name}] = Screen_Name::Spec.new( @my_cache, :#{name} )
        end

        @my_cache[:#{name}]
      end
      EOF
    }

    def it_redirects code, path, new_path
      it "redirects w/ #{code} #{path} -> #{new_path}" do
        get path
        redirects_to new_path, code
      end
    end

    def days_ago_in_sql days
      Sequel.lit(Okdoki::Model::PG::UTC_NOW_RAW + " - interval '#{days * 24} hours'")
    end

    def less_than x
      lambda { |o| o < x }
    end

    def within_secs x
      lambda { |o|
        o.class.should.equal Time
        !!o && (Time.now.utc.to_i - o.to_i).abs < x
      }
    end

    def new_body
      @i ||= 0
      "text #{@i += 1}"
    end

    def should_args action, *args
      case action
      when :zero, 0
        [ args.shift, [], :==, [0] ]
      when :one, 1
        [ args.shift, [], :==, [1] ]
      when Proc
        [ args.shift, [], nil, [action] ]
      else
        expect = args.shift
        actual = args.shift
        [ actual, [], action, args.unshift(expect) ]
      end
    end

    def assert *args
      make_should *should_args(*args)
    end

    def assert_not old_args
      args = should_args(*old_args)
      args[1].push :not
      make_should *args
    end

    def make_should o, bes_nots, meth, args
      s = Should.new(o)
      (bes_nots || []).each { |m|
        s = s.send(m)
      }

      if meth
        s.be.send(meth, *args)
      else
        s.be(*args)
      end
    end


    def utc_string
      Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
    end

    def ssl_hash
      {'HTTP_X_FORWARDED_PROTO' => 'https', 'rack.url_scheme'  => 'https' }
    end

    def last_response_should_be_xml
      last_response.headers['Content-Type'].should == 'application/xml;charset=utf-8'
    end

    def follow_ssl_redirect!
      follow_redirect!
      follow_redirect!
    end

    def assert_equal a, b
      a.should == b
    end

    def should_render *args
      should_render! *args
      should_render_assets
    end

    def should_render! txt = nil
      last_response.should.be.ok

      if txt
        last_response.body.should.match %r!#{txt}!
      end

      [ nil, last_response.body.bytesize.to_s ]
      .should.include last_response['Content-Length']
    end

    def should_render_assets
      files = last_response.body \
        .scan( %r!"(/[^"]+.(js|css|png|gif|ico|jpg|jpeg)[^"]*)"!i ) \
        .map(&:first)

      files.each { |f|
        get f
        last_response.should.be.ok
      }
    end

    def assert_raises_with_message( err_class, err_msg, &blok )
      err = assert_raises(err_class, &blok)
      case err_msg
      when String
        err_msg.should ==  err.message
      when Regexp
        err_msg.should.match err.message
      else
        raise ArgumentError, "Unknown class for error message: #{err_msg.inspect}"
      end
    end

    # 301 - Permanent
    # 302 - Temporay
    def assert_redirect(loc, status = 301)
      l = last_response.headers['Location']
      if !l
        fail "Not a redirect."
      end
      l.sub('http://example.org', '').should == loc
      last_response.status.should == status
    end

    def should_redirect *args
      assert_redirect(*args)
    end

    # For: backwards compatbility
    def assert_last_response_ok
      200.should == last_response.status
    end

    attr_reader :html, :http_code,
      :curl_cmd,
      :redirect_url, :last_request, :content_type, :raw_output

    def header key, val
      @header ||= {}
      @header[key] = val
    end

    def head path
      http_method 'HEAD', path
    end

    def get path
      http_method 'GET', path
    end

    def http_method meth, path
      meth_opt = "-X #{meth}"
      @last_response = nil
      @last_request = begin
                        o = OpenStruct.new
                        o.path_info = path.sub(/^https?:\/\/.+:\d+/i, '')
                        o.fullpath  = path
                        o
                      end

      headers = (@header || {}).
        map { |pair| "--header \"#{pair.first}: #{pair.last}\""}.
      join(' ')

      url = if path[/^https?:\/\//i]
              path
            else
              "http://localhost:#{ENV['PORT']}#{path}"
            end

      tmp_file = "/tmp/megauni.tmp.#{rand(100)}"
      @curl_cmd = %^bin/get -o #{tmp_file} #{headers} #{meth_opt} -w '\n%{http_code}||%{redirect_url}||%{content_type}' "#{url}"^
      raw = `#{curl_cmd}`

      @raw_output   = if File.exists?(tmp_file)
                        content = File.read(tmp_file)
                        `rm #{tmp_file}`
                        content
                      else
                        nil
                      end

      @html         = @raw_output

      info          = raw.split("\n").last.split '||'
      @http_code    = info.shift.to_i
      @redirect_url = (info.shift || '').sub(/^https?:\/\/.+:\d+/i, '')
      @content_type = info.last
      last_response
    end # === def get

    def follow_redirect!
      fail "Can't redirect on #{http_code.inspect}" unless [301, 302].include?(http_code)
      get(redirect_url)
    end

    def redirects_to *args
      case
      when args.size == 1
        path, code = args
      when args.size == 2 && args.first.is_a?(String)
        path, code = args
      when args.size == 2 && args.first.is_a?(Numeric)
        code, path = args
      else
        fail "Unknown args: #{args.inspect}"
      end

      if code
        http_code.should == code 
      else
        [301, 302, 303].should.include http_code
      end

      if path[/^\//]
        redirect_url.sub(/^https?:\/\/localhost:\d+/, '').should == path
      else
        redirect_url.should == path
      end
    end

    def last_response
      @last_response ||= begin
                           o = OpenStruct.new
                           o.status   = http_code
                           o.body     = html
                           o.fullpath = redirect_url
                           def o.ok?
                             status == 200
                           end
                           o
                         end
    end

  end # === Context ==============================
end # === Bacon ==================================












































