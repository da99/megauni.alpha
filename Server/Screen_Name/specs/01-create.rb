
describe "Screen Name: create" do

  it "creates record if data validates" do
    name = "name_#{rand(10000)}_validates"
    sn = Screen_Name.create(:screen_name=>name)
    Screen_Name::TABLE.where(:id=>sn.data[:id])
    .first[:screen_name]
    .should.equal name.upcase
  end

  it "raises Invalid if screen name is empty" do
    catch(:invalid) {
      Screen_Name.create({:screen_name=>""})
    }.
    error[:msg].
    should.match(/Screen name must be between /)
  end

  it "megauni is not allowed (despite case)" do
    catch(:invalid) {
      Screen_Name.create(screen_name: 'meGauNi')
    }.
    error[:msg].
    should.match(/Screen name not allowed: /)
  end

  it "raises Invalid for duplicate name" do
    name = "name_invalid_#{rand(10000)}"
    catch(:invalid) {
      Screen_Name.create(:screen_name=>name)
      Screen_Name.create(:screen_name=>name)
    }.
    error[:msg].
    should.match(/Screen name already taken: #{name}/i)
  end

  it "updates :owner_id (of returned SN obj) to its :id if Customer is new and has no id" do
    name = "name_name_#{rand(10000)}"
    sn = Screen_Name.create(:screen_name=>name)
    sn.data[:id].should == sn.data[:owner_id]
  end

  it "uses Customer :id as it's :owner_id" do
    o = Customer.create(
      screen_name: "sn_1235_#{rand(10000)}",
      pass_word: "this is my weak password",
      confirm_pass_word: "this is my weak password",
      ip: '00.000.000'
    )
    Screen_Name::TABLE.where(owner_id: o.data[:id]).first[:owner_id].should == o.data[:id]
  end

end # === describe





