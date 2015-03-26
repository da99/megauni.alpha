
story 'Old Apps Render Ok'

test('/', "Homepage must have a link to BusyNoise.") {
  click_on(:link, 'a[@href="/busy-noise/"]')
}

test('/busy-noise/', "BusyNoise must have beep MP3.") {
  file_must_exist('http://megauni.s3.amazonaws.com/beeping.mp3')
}

test('/', "Homepage must have a link to MyEggTimer.") {
  click_on('a', '/my-egg-timer/');
}

test('/create-account/', "Sign-up must have a working form to create-account.") {
  form('#form_create_account') {
    fill_in('input[@name="username"]', "da01#{rand(100000)}");
    fill_in('input[@name="password"]', "test123test123");
    fill_in('input[@name="confirm_password"]', "test123test123");
    click_on( :submit_button, 'button.submit');
  }
}

test('/account/', "Account page must render ok")

suites = Dir["specs/js/*.rb"].sort.each do |file|
  content = Pow("specs/js", file ).read
  h8ter = H8JS.new
  h8ter.instance_eval content
end

before {
  raise_if get? && !xhr? && next expectation not found
}
require 'launchy'
class H8JS
  
  def initialize
  @started = false
  end
  
  def started?
    @started
  end

  def expects
    @expects ||=[]
  end

  def no_expects_pending
    raise expects.inspect if !expects.empty?
  end

  def add_expect hash
    self.expects << hash
  end
  
  def expect_page_load( val )
    no_expects_pending
    self.expects << [:page_load, val]
  end
  
  def go_to( path, &blok )
    expect_page_load path, to_js(&blok)
    
    if started?
    else
      @started = true
      Launchy.open path    
    end
  end

  def write_as_js txt
    @new_cache ||= ''
    @new_cache += ( txt + "\n" )
  end

  def get_as_js
    raise ":write_as_js has not been called." if !@new_cache
    new_cache = @new_cache
    @new_cache = nil
    new_cache
  end

  def to_js &blok
    instance_eval( &blok )
    get_as_js
  end

  def click_on(a_ele, path)
    id = "a[@link='#{path}']"
    write_as_js( " H8JS.click_on( %s, %s, ); " % [a_ele.inspect, path.inspect] )
    
  end

end
