# models/Member.rb

class Test_Model_Member_Update < Test::Unit::TestCase

  must 'allow password to be reset' do
    mem = create_member
    mem.reset_password
    assert_equal true, mem.password_in_reset?
  end

  must 'raise Password_Reset::In_Reset during authentication if password is in reset' do
    pwrd   = 'test12345'
    mem    = create_member(:password => pwrd, :confirm_password => pwrd)
    mem.reset_password
    assert_raise Password_Reset::In_Reset do
      Member.authenticate(:username => mem.lifes.usernames.first, :password=>pwrd)
    end
  end

  must 'set code for password reset' do
    mem = create_member
    code = mem.reset_password.code
    assert_equal true, (code.size > 6)
  end

  must 'allow multiple password resets' do
    mem = create_member
    old_code = nil
    6.times { |i|
      code = mem.reset_password
      assert_not_equal code, old_code
      old_code = code
    }
  end

  must 'replace old password reset codes with new ones' do
    mem = create_member
    old_codes = (1..2).to_a.map { |i|
      mem.reset_password.code
    }
    
    mem.reset_password
    
    old_codes.each { |code|
      assert_raises(Password_Reset::Invalid_Code) do 
        mem.change_password_through_reset(
          :manipulator => mem, 
          :code=>code, :password=>"new_password", :confirm_password=>"new_password")
      end
    }
  end

  must 'use latest password reset code even if others were generated previously.' do
    mem = create_member
    old_codes = (1..2).to_a.map { |i|
      mem.reset_password
    }
    
    latest = mem.reset_password
    
    mem.change_password_through_reset(
      :manipulator => mem, 
      :code=>latest.code, 
      :password=>"new_password", 
      :confirm_password=>"new_password"
    )
    assert_equal false, mem.password_in_reset?
  end
  
  must 'return True for :password_in_reset? after calling :reset_password' do
    mem = create_member
    mem.reset_password
    assert_equal true, mem.password_in_reset?
  end

  must 'return false for :password_in_reset? after calling :change_password_through_reset' do
    mem = create_member
    reset = mem.reset_password
    mem.change_password_through_reset(
      :manipulator => mem, 
      :code=>reset.code, 
      :password=>"new_password", 
      :confirm_password=>"new_password"
    )
    assert_equal false, mem.password_in_reset?
  end

  must 'allow allow authentication with new password after reset' do
    pwrd = 'test12345t6'
    new_pwrd = "12345test"
    mem = create_member :password=>pwrd, :confirm_password=>pwrd
    code = mem.reset_password.code
    target = Member.by_id(mem.data._id)
    target.change_password_through_reset(
      :code=>code, 
      :password=>new_pwrd, 
      :confirm_password=>new_pwrd,
      :manipulator => target 
    )

    final = Member.by_id(mem.data._id)
    assert Member.authenticate(:username=>mem.lifes.usernames.first, :password=>new_pwrd)
  end

  must 'raise Member::Invalid if new password/confirmation do not match' do
    new_pwrd="1235test"
    mem = create_member
    code = mem.reset_password.code

    target = Member.by_id(mem.data._id)
    assert_raise(Member::Invalid) {
      target.change_password_through_reset(
        :manipulator => target, 
        :code=>code, :password=>new_pwrd, :confirm_password=>'somethig')
    }
  end

  must 'raise Invalid_Password_Reset_Code if code does not match for new password.' do
    new_pwrd="1235test"
    mem = create_member
    mem.reset_password

    target = Member.by_id(mem.data._id)
    assert_raise(Password_Reset::Invalid_Code) {
      target.change_password_through_reset(
        :manipulator => target, 
        :code=>'something', :password=>new_pwrd, :confirm_password=>new_pwrd)
    }
  end


end # === class Test_Model_Member_Update
