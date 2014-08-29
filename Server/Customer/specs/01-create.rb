
require './Server/Customer/model'

include Customer_Test

PASS_WORD="this_is_my pass word"

describe 'create:' do

  it 'checks min length of screen_name' do

    lambda {
      Customer.create screen_name: "a",
      pass_word: "this is my password",
      confirm_pass_word: "this is my password",
      ip: '000.00.00'
    }.should.raise(Screen_Name::Invalid).
    message.
    should.match /Screen name must be: 4-\d\d valid chars/

  end # === it

  it 'checks max length of screen_name' do
    screen_name = "123456789012345678901234567"
    lambda {
      Customer.create(
        screen_name: screen_name,
        pass_word: PASS_WORD,
        confirm_pass_word: PASS_WORD,
        ip: '00.000.000'
      )
    }.should.raise(Screen_Name::Invalid).
    message.should.match /Screen name must be: 4-\d\d valid chars/
  end

  it 'checks min length of pass_word' do
    lambda {
      Customer.create screen_name: new_name,
      pass_word: "t",
      confirm_pass_word: "t",
      ip: '000.00.00'
    }.should.raise(Customer::Invalid).
    message.
    should.match /Pass phrase is too short./
  end # === it

  it 'checks max length of pass_word' do
    pswd = "100000 10000 " * 100
    lambda {
      Customer.create(
        screen_name: new_name,
        pass_word: pswd,
        confirm_pass_word: pswd,
        ip: '00.000.000'
      )
    }.should.raise(Customer::Invalid).
    message.
    should.match /Pass phrase is too big/
  end

  it 'checks pass_phrase and confirm_pass_phrase match' do
    screen_name = "123456789";
    lambda {
      Customer.create(
        screen_name: screen_name,
        pass_word: PASS_WORD,
        confirm_pass_word: PASS_WORD + "a",
        ip: '00.000.000'
      )
    }.should.raise(Customer::Invalid).
    message.should.match /Pass phrase is different than pass phrase confirmation/
  end

  it 'saves screen_name to Customer object' do
    o = create_screen_name
    assert :==, o[:c].screen_names.map(&:screen_name), [o[:sn].screen_name.upcase]
  end

  it 'saves Customer id to Customer object' do
    o = create_screen_name

    # Has the customer id been saved?
    assert :is_a, Numeric, o[:c].data[:id]
  end

end # === desc create


