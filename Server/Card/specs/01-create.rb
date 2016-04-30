


describe "Computer: create" do

  before do
    @code = [
      "path" , ["/"],
      "a"    , ["a"],
      "val"  , ["\""]
    ]
  end

  it "escapes :code" do
    r = Computer.create(
      owner_id: 1,
      code: {:instructs=>@code}
    )
    raw = Computer::TABLE.where(:id=>r.data[:id]).first
    Escape_Escape_Escape.json_decode(raw[:code])['instructs'].should == @code
  end

  it 'turns value into a Hash' do
    r = Computer.create(:owner_id=>1, :code=>[])
    Escape_Escape_Escape.json_decode(r.data[:code]).
      should == {'code'=>[]}
  end


end # === describe Code: create ===


