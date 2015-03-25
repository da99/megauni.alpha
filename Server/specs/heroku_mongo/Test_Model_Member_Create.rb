# models/Member.rb


class Test_Model_Member_Create < Test::Unit::TestCase

  RAND_NUMS = (1..100).to_a.map {|a| rand(10000)}.uniq
  def random_username
    "da01_#{RAND_NUMS.pop}"
  end

  must 'raise Unauthorized if editor is not nil' do
    err = assert_raise( Member::Unauthorized ) do
      Member.create( 
        Member.new, 
        :password=>'pass12pass', 
        :confirm_password=>'pass12pass', 
        :add_username=>random_username,
        :category  => 'real'
      )
    end
    assert_match( /\ACreator: /, err.message )
  end

  must 'require a password' do
    doc = begin
            Member.create( nil, {
              :password => nil,
              :add_username => random_username,
              :category  => 'real'
            })
          rescue Member::Invalid => e
            e.doc
          end
    assert_equal "Password is required.", doc.errors.first
  end

  must 'require :add_username' do
    doc = begin
            Member.create(nil, {:password => 'pass123pass', 
                                :confirm_password => 'pass123pass',
                                :add_username => nil,
                                :category  => 'real'
            })
          rescue Member::Invalid => e
            e.doc
          end
    assert_equal "Username is too small. It must be at least 2 characters long.", doc.errors.detect { |msg| msg['small'] }
  end

  must 'require a unique username' do
    old_mem_id = Member.db.collection.find_one()['_id']
    mem = Member.by_id(old_mem_id)
    username = mem.lifes.usernames.first
    doc = begin
            Member.create(nil, {:password => 'pass132pass',
                                :confirm_password=>'pass132pass',
                                :add_username => username,
                                :category  => 'real'
            })
          rescue Member::Invalid => e
            e.doc
          end
    assert_equal(
        "Username, #{username}, already taken. Please choose another.", 
        doc.errors.detect { |msg| msg =~ /sername/ }
    )
  end

  must 'use a safe insert into Lifes collection (in MongoDB) when creating a life.' do
    Life.db.collection.expects(:insert).returns('new_id').with do | doc, opts |
      opts[:safe] == true 
    end
    create_member
  end

  must 'add a UUID to data._id' do
    doc = Member.create(nil, {
      :password => "pass123pass", 
      :confirm_password => "pass123pass",
      :add_username=>random_username,
      :category => 'real'
     }
    )
    # assert_match( /\A[a-z0-9\-]{10,}\Z/i, doc.data._id.to_s )
    assert_equal(BSON::ObjectId, doc.data._id.class)
  end

  must 'return false for new?' do
    doc = Member.create(nil, {
      :password => "pass123pass", 
      :confirm_password => "pass123pass",
      :add_username=>random_username,
      :category  => 'real'
     }
    )
    assert_equal( false, doc.new? )
  end

  must 'set security level to "MEMBER"' do
    doc = Member.create(nil, {
      :password => "pass123pass", 
      :confirm_password => "pass123pass",
      :add_username=>random_username,
      :category  => 'real'
     }
    )
    assert_equal( "MEMBER", doc.data.security_level )
  end

  must 'have power of "MEMBER"' do
    doc = Member.create(nil, {
      :password => "pass123pass", 
      :confirm_password => "pass123pass",
      :add_username=>random_username,
      :category  => 'real'
     }
    )
    assert_equal( true, doc.has_power_of?("MEMBER") )
  end

  must 'not have power of "Admin"' do
    doc = Member.create(nil, {
      :password => "pass123pass", 
      :confirm_password => "pass123pass",
      :add_username=>random_username,
      :category  => 'real'
     }
    )
    assert_equal( false, doc.has_power_of?("ADMIN") )
  end

end # === class _create
