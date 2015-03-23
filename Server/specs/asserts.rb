
class Bacon::Context
  
  # === Custom Helpers ===

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

end # === Bacon::Context

