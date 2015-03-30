


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
      code: @code
    )
    raw = Computer::TABLE.where(:id=>r.data[:id]).first
    raw[:code].should == @code
  end

  it 'allows path: ""' do
    @code[1] = [""]
    r = Computer.create @sn, MultiJson.dump(@code)
    raw = Computer::TABLE.where(:id=>r.id).first
    raw[:path].should == ''
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


