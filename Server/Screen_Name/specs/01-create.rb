
describe "Screen Name: create" do

  it "creates record if data validates" do
    name = new_name
    sn = Screen_Name.create(:screen_name=>name, :customer=>Customer.new({}))
    Screen_Name::TABLE.where(:id=>sn.data[:id])
    .first[:screen_name]
    .should.equal name.upcase
  end

  it "raises Invalid if screen name is empty" do
    lambda {
      Screen_Name.create({:screen_name=>"", :customer=>Customer.new({})})
    }.should.raise(Screen_Name::Invalid).

    message.
    should.match(/Screen name must be: /)
  end

  it "megauni is not allowed (despite case)" do
    lambda {
      Screen_Name.create({:screen_name=>'meGauNi', :customer=>Customer.new({})})
    }.should.raise(Screen_Name::Invalid).

    message.
    should.match(/Screen name not allowed/)
  end

  it "raises Invalid for duplicate name" do
    name = new_name
    lambda {
      Screen_Name.create(:customer=>Customer.new({}), :screen_name=>name)
      Screen_Name.create(:customer=>Customer.new({}), :screen_name=>name)
    }.should.raise(Screen_Name::Invalid).

    message.
    should.match(/Screen name already taken: #{name}/i)
  end

  it "updates :owner_id (of returned SN obj) to its :id if Customer is new and has no id" do
    name = new_name
    sn = Screen_Name.create(:screen_name=>name, :customer=>Customer.new({}))
    assert :equal, sn.data[:id], sn.data[:owner_id]
  end

  it "updates :owner_id (of customer.clean_data) to its :id if Customer is new and has no id" do
    name = new_name
    c    = Customer.new({})
    sn   = Screen_Name.create(:screen_name=>name, :customer=>c)
    assert :equal, sn.data[:id], c.clean_data[:id]
  end

  it "does not update it's :owner_id if Customer has data[:id]" do
    name = new_name
    c    = Customer.new({id: 1})
    sn   = Screen_Name.create(:screen_name=>name, :customer=>c)
    assert :equal, 1, Screen_Name::TABLE.where(id: sn.id).first[:owner_id]
  end

end # === describe

# describe "Screen_Name :create :i_know_them" do

  # before do
    # # I_Know_Them::TABLE.delete
  # end

  # it "returns an I_Know_Them with :target_id = target.id" do
    # ikt = S1.create :i_know_them, S2
    # assert :==, ikt.target_id, S2.id
  # end

  # it "returns an I_Know_Them with :owner_id = owner.id" do
    # ikt = S1.create :i_know_them, S2
    # assert :==, ikt.owner_id, S1.id
  # end

  # it "is a follow by default" do
    # ikt = S1.create :i_know_them, S2
    # assert :==, true, ikt.is_follow
  # end

# end # === describe  ===



















