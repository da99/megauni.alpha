

class Test_Model_Member_Read < Test::Unit::TestCase


  must 'return user if username/password pass authentication' do
    doc = Member.authenticate(:username=>regular_username(1), :password=>regular_password(1))
    assert_equal(
      regular_username(1),
      doc.lifes.usernames.detect { |un| un == regular_username(1) }
    )
  end

  must 'Mongo_Dsl::Not_Found is user is not found during authentication' do
    assert_raise(Mongo_Dsl::Not_Found) do
      Member.authenticate(:username=>'billy_west', :password=>'my-name-is-my-password')
    end
  end

  must 'raise Member::Wrong_Password if username is correct, password is incorrect' do
    mem, un, pass = generate_random_member
    assert_raise(Member::Wrong_Password) do
      Member.authenticate(:username=>un, :password=>'yoyo-homeslice')
    end
  end

  must 'return user if authentication passes, despite previous failed attempts' do
    mem, un, pass = generate_random_member
    begin
      Member.authenticate(:username=>un, :password=>'yoyo-again')
    rescue Member::Wrong_Password
    end
    
    doc = Member.authenticate(:username=>un, :password=>pass)
    assert_equal(doc.data._id, mem.data._id)
  end


  must 'raise Password_Reset::In_Reset after 3 failed authentication attempts, no matter if correct password' do
    mem, username, pass = generate_random_member
    3.times do 
      begin
        Member.authenticate :username=>username, :password=>'yoyo-i-want-vitamins' 
      rescue Member::Wrong_Password
      rescue Password_Reset::In_Reset
      end
    end

    assert_raise(Password_Reset::In_Reset) do
      Member.authenticate :username=>username, :password=>pass
    end
  end

  must 'return failed attempts for current day' do
    mem, username, pass = generate_random_member
    [1,2,3].each do |i|
      begin
        Member.authenticate :username=>username, :password=>'yoyo-i-want-vitamins' 
      rescue Member::Wrong_Password
      rescue Password_Reset::In_Reset
      end
      assert_equal( i, Failed_Log_In_Attempt.for_today(mem).count )
    end
  end

  must 'stop inserting failed attempts after the 3rd attempt' do
    mem, username, pass = generate_random_member
    5.times do
      begin
        Member.authenticate :username=>username, :password=>'yoyo-i-want-vitamins' 
      rescue Member::Wrong_Password
      rescue Password_Reset::In_Reset
      end
    end

    assert_equal( 3, Failed_Log_In_Attempt.for_today(mem).size )
  end

  must 'raise Member::Invalid_Security_Level if :has_power_of? given invalid parameter.' do
    mem = regular_member(2)
    assert_raise Member::Invalid_Security_Level do
      mem.has_power_of?(nil)
    end
  end

end # === class Member_Read


__END__


# 
#   must 'add :owner_username to a collection of docs with :owner_id (:username_id)' do
#     mem_1 = regular_member(1)
#     mem_2 = regular_member(2)
#     un_id_1 = mem_1.lifes._ids.first
#     un_id_2 = mem_2.lifes._ids.last
#     un_1    = mem_1.lifes.usernames.first
#     un_2    = mem_2.lifes.usernames.last
#     
#     docs = []
#     docs << {'title'=>'something', 'owner_id'=> un_id_1}
#     docs << {'title'=>'something', 'owner_id'=> un_id_2}
#     
#     results = Member.add_docs_by_username_id(docs).map { |doc| doc['owner_username'] }
#     target = [un_1, un_2]
#     assert_equal target, results
#   end
