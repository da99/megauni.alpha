
require './Server/Customer/model'

include Customer_Test

IP = '127.0.0.1'

describe 'read_by_id:' do

  it 'reads Customer from DB using customer id' do
    o  = find_customer 1
    id = o[:c].id
    c  = Customer.read_by_id(id)

    assert :==, id, c.data[:id]
  end

  it 'raises Customer::Not_Found' do
    lambda {
      Customer.read_by_id(0)
    }.should.raise(Customer::Not_Found).
    message.
    should.match(/Customer not found/)
  end

end # === describe read_by_id ===


describe 'read_by_screen_name_and_pass_word' do

  before do
    # Customer::Log_In_By_IP::TABLE.delete
    Customer::TABLE.
      update(bad_log_in_count: 0)
    Customer::Log_In_By_IP::TABLE.
      where(ip: IP).
      update(bad_log_in_count: 0)

    @o  = find_customer
    @c  = @o[:c]
    @sn = @o[:sn]
  end

  it 'reads customer if passed a hash with: screen_name, correct pass_word' do
    c = Customer.read_by_screen_name_and_pass_word(@sn, @o[:pw], IP)
    assert :==, @c.id, c.id
  end

  it 'raises Customer::Wrong_Pass_Word if passed a hash with: screen_name, incorrect pass_phrase' do
    lambda {
      Customer.read_by_screen_name_and_pass_word @sn, 'no pass phrase', IP
    }.should.raise(Customer::Wrong_Pass_Word).
    message.should.
    match(/Pass phrase is incorrect. Check your CAPS LOCK key/)
  end

  it 'increases :bad_log_in_count by 1 if incorrect pass_phrase supplied' do
    Customer::TABLE.
      where(:id=>@c.id).
      update(bad_log_in_count: 3)

    begin
      Customer.read_by_screen_name_and_pass_word @sn.screen_name, 'no pass phrase', IP
    rescue Customer::Wrong_Pass_Word
    end

    c = Customer::TABLE[id: @c.id]
    assert :==, 4, c[:bad_log_in_count]
  end

  it 'increases IP :bad_log_in_count by 1 if incorrect pass word, correct screen name supplied' do
    begin
      Customer.read_by_screen_name_and_pass_word @sn, "incorrect", IP
    rescue Customer::Wrong_Pass_Word
    end
    r = Customer::Log_In_By_IP::TABLE[ip: IP]
    assert :==, 1, r[:bad_log_in_count]
  end

  it 'increases IP :bad_log_in_count by 1 if incorrect pass word, unknown screen name supplied' do
    begin
      Customer.read_by_screen_name_and_pass_word "uknown sn", "incorrect", IP
    rescue Screen_Name::Not_Found
    end
    r = Customer::Log_In_By_IP::TABLE[ip: IP]

    r[:bad_log_in_count]
    .should == 1
  end

  it 'updates log_in_at to PG current_date when logging in' do
    d = DB["SELECT current_date AS date"].first[:date]

    # ensure old date for log_in_at
    Customer::TABLE.update(:log_in_at => '1999-01-01')

    last = Customer.read_by_screen_name_and_pass_word @sn, @o[:pw], IP

    assert :==, d.to_s, last.data[:log_in_at].to_s
  end

  it 'updates log_in_at of IP TABLE to PG current_date when logging in' do
    d = DB["SELECT current_date AS date"].first[:date]

    # ensure ip entry exists
    Customer.read_by_screen_name_and_pass_word @sn, @o[:pw], IP

    # ensure old date in IP TABLE
    Customer::Log_In_By_IP::TABLE.update(:log_in_at => '1999-01-01')

    # Log in again.
    Customer.read_by_screen_name_and_pass_word @sn, @o[:pw], IP

    assert :==, d.to_s, Customer::Log_In_By_IP::TABLE.where(ip: IP).first[:log_in_at].to_s
  end

  it 'returns Too_Many_Bad_Logins if: correct pass phrase, too many bad log-ins' do
    Customer::TABLE.
      where(id: @c.id).
      update(log_in_at: Okdoki::Model::PG::UTC_NOW, bad_log_in_count: 4)

    lambda {
      Customer.read_by_screen_name_and_pass_word @sn, @o[:pw], IP
    }.should.raise( Customer::Too_Many_Bad_Logins ).
      message.
      should.match(/Too many bad log-ins for today. Try again tomorrow/)
  end

  it 'returns Too_Many_Bad_Logins if: correct pass phrase, no bad log ins by screen name, ' +
    ' too many bad log-ins by IP' do
    Customer::Log_In_By_IP::TABLE.
      where(ip: IP).
      update(log_in_at: Okdoki::Model::PG::UTC_NOW, bad_log_in_count: 4)

    lambda {
      Customer.read_by_screen_name_and_pass_word @sn, @o[:pw], IP
    }.should.raise( Customer::Too_Many_Bad_Logins ).
      message.
      should.match(/Too many bad log-ins for today. Try again tomorrow/)
  end

end # === describe :read_by_screen_name_and_pass_word

describe "Customer :screen_names" do

  before do
    @o  = find_customer
    @c  = @o[:c]
    @sn = @o[:sn]
  end

  it "gets latest ids after multiple :create :screen_name, NAME" do
    ids = [@sn.id]
    4.times do |i|
      n = new_name
      ids.push @c.create(:screen_name, n).id
    end

    @c.screen_names.map(&:id).sort
    .should.equal ids.sort
  end


end # === describe Customer :screen_names ===

describe ":href" do

  it "returns Customer href of first screen name" do
    o = create_screen_name
    c = o[:c]
    s = o[:sn]

    c.href.should == "/@#{s.screen_name.upcase}"
  end

end # === describe :href ===








