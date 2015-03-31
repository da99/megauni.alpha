
describe 'Link.read' do

  it "allows: STRANGER -> POST from PUBLIC SCREEN_NAME" do
    sn = Screen_Name.create(screen_name: "sn_#{rand(10000)}")
    Screen_Name.update(id: sn.data[:id], privacy: 1)
    computer = Computer.create(
      owner_id: sn.data[:id],
      code: {}
    )

    link = Link.read(
      consumer_id: nil,
      target_id:   computer.data[:id],
      type_id:     :read_computer
    )

    link[:target_id].should == computer.data[:id]
  end

  it "disallows: STRANGER -> POST from PROTECTED SCREEN_NAME" do
    sn = Screen_Name.create(screen_name: "sn_#{rand(10000)}")
    Screen_Name.update(id: sn.data[:id], privacy: 2)
    computer = Computer.create(
      owner_id: sn.data[:id],
      code: {}
    )

    link = Link.read(
      consumer_id: nil,
      target_id:   computer.data[:id],
      type_id:     :read_computer
    )

    link.should = nil
  end

  it "allows: OWNER -> POST from PRIVATE SCREEN_NAME"

  it "allows: CUSTOMER -> POST from PRIVATE SCREEN_NAME w/exceptions"

end # === describe 'Link.read'
