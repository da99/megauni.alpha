

require './Server/Consume/model'
require './Server/Screen_Name/specs/helpers'
require './Server/Computer/model'
require './Server/Computer/specs/helpers'

describe "Code: .update" do

  before do
    Computer_Test.delete
    @sn = Screen_Name_Test.list(0)
  end

  it "updates record in database" do
    str = MultiJson.dump(['a', []])
    r = Computer.create @sn, "read-screen-name", "[]"
    r.update @sn, :code=> str
    Computer::TABLE.where(id: r.id)
    .first[:code].should == str
  end

  it "updates :class_id using :class_name given" do
    code = ['a', ["\""]]
    r = Computer.create @sn, "VIEW-screen-name", "[]"
    r.update @sn, :class_name=>'read-screen-name'
    r.data[:class_id].should == File_Name.read('read-screen-name').id
  end

  it "escapes :code" do
    code = ['a', ["\""]]
    r = Computer.create @sn, "read-screen-name", "[]"
    r.update @sn, :code=> MultiJson.dump(code)

    Computer::TABLE.where(id: r.id)
    .first[:code].should == MultiJson.dump(Okdoki::Escape_All.escape code)
  end

  it "updates its @data" do
    code = ['a', ["\""]]
    r = Computer.create @sn, "read-screen-name", "[]"
    r.update @sn, :code=> MultiJson.dump(code)

    r.data[:code].should == MultiJson.dump(Okdoki::Escape_All.escape code)
  end

end # === describe Code: update ===


