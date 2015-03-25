
PASS_WORD="this_is_my pass word"

describe 'create:' do

  it 'checks min length of screen_name' do

    catch(:invalid) {
      Customer.create screen_name: "a",
      pass_word: "this is my password",
      confirm_pass_word: "this is my password",
      ip: '000.00.00'
    }.error[:msg].
    should.match /Screen name must be between 4 and \d\d char/

  end # === it

  it 'checks max length of screen_name' do
    screen_name = "123456789012345678901234567"
    catch(:invalid) {
      Customer.create(
        screen_name: screen_name,
        pass_word: PASS_WORD,
        confirm_pass_word: PASS_WORD,
        ip: '00.000.000'
      )
    }.
    error[:msg].should.match /Screen name must be: 4-\d\d/
  end

  it 'checks min length of pass_word' do
    new_name = "1234567"
    catch(:invalid) {
      Customer.create(
        screen_name: new_name,
        pass_word: "t",
        confirm_pass_word: "t",
        ip: '000.00.00'
      )
    }.
    error[:msg].should.match /Pass phrase is not long enough/
  end # === it

  it 'checks max length of pass_word' do
    new_name = "name_name_#{rand(10000)}"
    pswd = "100000 10000 " * 100
    catch(:invalid) {
      Customer.create(
        screen_name: new_name,
        pass_word: pswd,
        confirm_pass_word: pswd,
        ip: '00.000.000'
      )
    }.
    error[:msg].should.match /Pass phrase is too big/
  end

  it 'checks pass_phrase and confirm_pass_phrase match' do
    screen_name = "123456789";
    catch(:invalid) {
      Customer.create(
        screen_name: screen_name,
        pass_word: PASS_WORD,
        confirm_pass_word: PASS_WORD + "a",
        ip: '00.000.000'
      )
    }.
    error[:msg].should.match /Pass phrase confirmation does not match/
  end

  it 'saves Customer id to Customer object' do
    o = Customer.create(
      screen_name: "sn_1235_#{rand(10000)}",
      pass_word: PASS_WORD,
      confirm_pass_word: PASS_WORD,
      ip: '00.000.000'
    )
    o.data[:id].class.should == Fixnum
  end

  it "does not return :pswd_hash" do
    o = Customer.create(
      screen_name: "sn_hash_#{rand(10000)}",
      pass_word: PASS_WORD,
      confirm_pass_word: PASS_WORD,
      ip: '00.000.000'
    )
    o.data.keys.include?(:pswd_hash).should == false
  end # === it does not return :pswd_hash

  it "has secret fields: :pswd_hash" do
    Customer.fields.select { |f, meta| meta[:secret] }.keys.
      should == [:pswd_hash]
  end # === it has secret fields: :pswd_hash

end # === desc create


