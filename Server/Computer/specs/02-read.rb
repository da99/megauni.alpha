
require './Server/Computer/model'
require './Server/Screen_Name/specs/helpers'

describe "Computer: read" do

  before do
    @sn1 = Screen_Name_Test.list 0
  end

  it "returns a WWW_Applet" do
    c = Computer.create @sn1, [ "sum", [1,2,3], "path", ["my_sum"] ]
    applet = Computer.read_by_path @sn1, "my_sum"
    applet.class.should == WWW_Applet
  end

end # === describe Computer: read ===


