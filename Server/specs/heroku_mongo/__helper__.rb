
ENV['RACK_ENV'] = 'test'


require 'rubygems'
require 'test/unit'
require 'mocha'
require 'test/unit/testresult'
require 'test/unit/testcase'
require 'helpers/app/Color_Puts'

require 'quietbacktrace'

class QuietBacktrace::BacktraceCleaner
  
  ALL_GEMS_SUB  = '/lib/ruby/gems' 
  # ALL_NOISE << '/middleware'
  # ALL_NOISE << '/tests/__helper__'
  ALL_NOISE << ALL_GEMS_SUB

  def body_clean(backtrace)
    total = backtrace.size
    brain = [backtrace[0]].compact
    head  = backtrace[1..3]     || []
    body  = backtrace[4..total] || []
    remove_first_slash( 
      filter(brain) + 
      filter(silence_all_gems(head)) + 
      filter(silence(body || []))
    ) 
  end
  alias_method :orig_clean, :clean
  alias_method :clean, :body_clean
  
  def silence_all_gems(backtrace)
    backtrace = backtrace.reject { |line| line[ALL_GEMS_SUB] }
    backtrace
  end
  
  def remove_first_slash(backtrace)
    backtrace.map { |line| 
      if line.lstrip[ /\A\// ]
        line.sub('/', '')
      else
        line
      end
    }
  end
  
end # === class



class Test::Unit::TestCase
  
  # === Custom Helpers ===

  def self.admin_member
    @admin_member ||= Life.find.username("admin-member-1").grab(:owner).go_first!
  end

  def self.regular_members
    @regular_mem ||= [1,2,3].map { |i| Life.find.username("regular-member-#{i}").grab(:owner).go_first! }
  end
  
  def regular_member i
    self.class.regular_members[1-1]
  end

  def regular_username i
    self.class.regular_members[i-1].lifes.usernames.first
  end

  def regular_password i
    'regular-password'
  end
      
  def log_in_regular_member i = 1
    mem = Life.find.username(regular_username(1)).grab(:owner).go_first!
    # BCrypt::Password.expects(:new).returns(regular_password(1) + mem.data.salt)
    Member.expects(:authenticate).returns(mem)
    assert_equal false, mem.has_power_of?( :ADMIN )
    post '/log-in/', {:username=>mem.lifes.usernames.first, :password=>regular_password(1)}, ssl_hash
    follow_redirect!
    assert_match( /lifes/, last_request.fullpath)
  end

  def mem
    regular_member(1)
  end

  def log_in_mem
    log_in_regular_member(1)
  end

  def admin_member
    self.class.admin_member
  end

  def admin_username
    self.class.admin_member.data.lifes.first.last[:username]
  end

  def admin_password
    'admin-password'
  end

  def generate_random_member
    chars    = ('a'..'z').to_a + ('A'..'Z').to_a
    username = (1..5).to_a.inject('') { |m,l| m << chars[rand(chars.size)]; m } + "#{rand(100)}"
    password = "random-password-#{rand(1000)}"
    mem = Member.create(nil,
      :add_username => username ,
      :password => password,
      :confirm_password => password,
      :category => 'real'
    )
    [mem, username, password]
  end

  def utc_string
    Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
  end

  def chop_last_2(str)
    if not str.is_a?(String)
      raise ArgumentError, "#{str.inspect} needs to be a String."
    end
    str[0, str.size - 2]
  end

  def ssl_hash
    {'HTTP_X_FORWARDED_PROTO' => 'https', 'rack.url_scheme'  => 'https' }
  end

  def last_response_should_be_xml
    assert_equal last_response.headers['Content-Type'], 'application/xml;charset=utf-8'
  end

  def follow_ssl_redirect!
    follow_redirect!
    follow_redirect!
  end

  def assert_raises_with_message( err_class, err_msg, &blok )
    err = assert_raises(err_class, &blok)
    case err_msg
    when String
      assert_equal err_msg, err.message
    when Regexp
      assert_match err_msg, err.message
    else
      raise ArgumentError, "Unknown class for error message: #{err_msg.inspect}"
    end
  end

  # 301 - Permanent
  # 302 - Temporay
  def assert_redirect(loc, status = 301)
    assert_equal loc, last_response.headers['Location'].sub('http://example.org', '')
    assert_equal status, last_response.status
  end

  def assert_last_response_ok
    assert_equal 200, last_response.status
  end

  def assert_log_out
    get '/lifes/'
    assert_redirect('/log-in/', 303)
  end

  def log_in_member(mem, password)
    assert_equal false, mem.has_power_of?( :ADMIN )
    post '/log-in/', {:username=>mem.lifes.usernames.first, :password=>password}, ssl_hash
    follow_redirect!
    assert_match( /lifes/, last_request.fullpath)
  end

  def log_in_admin
    mem = Life.find.username('admin-member-1').grab(:owner).go_first!
    assert mem.has_power_of?(:ADMIN)
    post '/log-in/', {:username=>mem.lifes.usernames.first, :password=>admin_password}, ssl_hash
    follow_redirect!
    assert_match( /lifes/, last_request.fullpath )
  end

  def create_member raw_opts = {}
    
    opts = Data_Pouch.new(raw_opts, :password, :confirm_password, :category, :add_username, :email)
    
    if !opts.add_username
      opts.add_username = "name#{rand(1000000)}"
    end
    
    if !opts.password && !opts.confirm_password
      new_pwrd              = "pass-#{opts.add_username}"
      opts.password         = new_pwrd
      opts.confirm_password = new_pwrd
    end
    
    if !opts.email
      opts.email = "test-#{rand(10000)}@megauni.com"
    end
    
    if !opts.category
      opts.category = 'real'
    end

    Member.create nil, opts.as_hash
  end

  def create_member_and_log_in(*args)
    mem = create_member(*args)
    log_in_member(mem, "pass-#{mem.lifes.usernames.first}")
    mem
  end

  def create_club(mem = nil, raw_club_opts = {})
    mem ||= regular_member(1)
    id        = rand(20000).to_s + object_id.to_s
    defaults  = {:filename=>"#{id}", :title=>"Club: #{id}", 
                       :teaser=>"Teaser for: Club #{id}"}
    club_opts = defaults.update(raw_club_opts)
    club      = Club.create(mem, club_opts )
  end

  def create_message( mem, club = nil, un_id_or_opts = nil )
    
    club ||= self.club
    
    opts, un_id = case un_id_or_opts
                  when Hash
                    [ un_id_or_opts, nil ]
                  when BSON::ObjectId
                    [ {}, un_id_or_opts]
                  else
                    [ {}, nil ]
                  end

    final_opts = {
      :privacy => 'public',
      :target_ids => [club.data._id],
      :owner_id => (un_id || mem.lifes._ids.first),
      :body => "random body #{rand(4000)}",
      :message_model => 'random'
    }.update(opts)

    Message.create( mem, final_opts )
  end

  def create_club_content
    club_1 = create_club
    club_2 = create_club
    mess_1 = create_message(regular_member(1), club_1)
    mess_2 = create_message(regular_member(2), club_2)
    {:clubs => [club_1, club_2], :messages=>[mess_1, mess_2]}
  end

  def add_username mem = nil
    mem ||= regular_member(1)
    un_2 = "rand_#{rand 3000}"
    Member.update(mem.data._id, mem, :add_username=>un_2)
    mem = Member.by_id(mem.data._id)
    uns     = mem.lifes.usernames
    un_ids  = uns.map { |u| mem.lifes._id_for(u) }
    [mem, uns, un_ids]
  end

  def club
    @club ||= begin
                doc  = Club.db.collection.find_one()
                Club.by_id(doc['_id'])
              end
  end

  
end

