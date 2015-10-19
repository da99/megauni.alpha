
require './Server/Consume/model'

describe "Code: up_create" do

  before do
    Code::TABLE.delete
    @sn = Screen_Name_Test.screen_name(1)
  end

  it "creates row if it does not exist" do
    r = Code.up_create @sn, "on view profile", "[]"
    raw = Code::TABLE.where(:screen_name_id=>@sn.id).first
    raw[:id].should == r.id
  end

  it "updates if row exists" do
    r = Code.up_create @sn, "on view profile", "[]"
    code = '["success_msg", ["hello"]]'
    Code.up_create @sn, "ON view profile", code
    raw = Code::TABLE.where(:screen_name_id=>@sn.id).first
    raw[:code].should == MultiJson.dump(Okdoki::Escape_All.escape(MultiJson.load(code)))
  end

end # === describe Code: up_create ===


