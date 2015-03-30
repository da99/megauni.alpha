


describe "Computer: create" do

  before do
    DB[Computer.table_name].delete
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

  it 'fails w/ArgumentError if code is not a Hash' do
    should.raise(ArgumentError) {
      Computer.create(:owner_id=>1, :code=>[])
    }.message.should.match /hash/
  end

  it "allows path: /" do
    @code[1] = ["/"]
    r = Computer.create @sn, MultiJson.dump(@code)
    raw = Computer::TABLE.where(:id=>r.id).first
    raw[:path].should == '/'
  end

  it "lowercases the path" do
    @code[1] = ['ABC/DEF/']
    r = Computer.create @sn, MultiJson.dump(@code)
    raw = Computer::TABLE.where(:id=>r.id).first
    raw[:path].should == 'abc/def/'
  end

  it "raises Invalid for path: /*" do
    @code[1] = ['/*']
    lambda {
      Computer.create @sn, MultiJson.dump(@code)
    }.should.raise(Computer::Invalid)
    .message.should.match /Not allowed. \/\*/
  end

end # === describe Code: create ===


