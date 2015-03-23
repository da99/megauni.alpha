


require 'ostruct'
require 'Bacon_Colored'
require 'pry'

PERM     = 301
TEMP     = 302
BING_URL = 'http://www.mises.org/'

def it_redirects code, path, new_path
  it "redirects w/ #{code} #{path} -> #{new_path}" do
    get path
    redirects_to new_path, code
  end
end


class Bacon::Context

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

end # === class


