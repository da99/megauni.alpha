

class Test_View_Base_View_Read < Test::Unit::TestCase

  must 'turn this url into an HTML A tag: http://gilesbowkett.blogspot.com/2010/03/automating-email-awesome-mini.html' do
    orig = "http://gilesbowkett.blogspot.com/2010/03/automating-email-awesome-mini.html"
    result = Base_View.new(Object.new).auto_link(orig)
    assert_equal "<a href=\"#{orig}\">#{orig}</a>", result
  end
  
  must 'turn valid http urls into HTML anchor tags' do
    result = Base_View.new(Object.new).auto_link('http://www.mises.org')
    assert_equal "<a href=\"http://www.mises.org\">http://www.mises.org</a>", result
  end

  must 'turn valid http urls with "%" into HTML anchor tags' do
    url = "http://www.alternet.org/news/147217/the_u.s._war_addiction%3A_funding_enemies_to_maintain_trillion_dollar_racket/?page=5"
    result = Base_View.new(Object.new).auto_link(url)
    assert_equal "<a href=\"#{url}\">#{url}</a>", result
  end

  must 'not turn javascript protocol into anchor tags.' do
    original = 'javascript:alert("hello")'
    result = Base_View.new(Object.new).auto_link(original)
    assert_equal original, result 
  end

  must 'not turn any url with more than 2 slash forwards into a link' do
    original = 'http:////www.lewrockwell.com/'
    result = Base_View.new(Object.new).auto_link(original)
    assert_equal original, result
  end

  must 'turn any \r\n or \n into <br />' do
    result = Base_View.new(Object.new).auto_link("hello \r\n goodbye \n hello")
    assert_equal "hello <br/> goodbye <br/> hello", result
  end


end # === class Test_View_Base_View_Read
