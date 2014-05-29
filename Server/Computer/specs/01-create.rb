

require './Server/Computer/model'
require './Server/Screen_Name/specs/helpers'
require './Server/Computer/specs/helpers'

describe "Computer: create" do

  before do
    Computer_Test.delete
    @sn = Screen_Name_Test.list(0)
    @code = [
      "path" , ["/"],
      "a"    , ["a"],
      "val"  , ["\""]
    ]
  end

  it "escapes :code" do
    r = Computer.create @sn, MultiJson.dump(@code)
    raw = Computer::TABLE.where(:id=>r.id).first
    raw[:code].should == MultiJson.dump(Okdoki::Escape_All.escape @code)
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

  it "removes beginning /" do
    @code[1] = ['/ABC/DEF/']
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

  it "raises Invalid if there are more than 5 records of STRING/.../* paths created" do
    lambda {
      6.times do |i|
        @code[1] = "book/#{i}/*"
        Computer.create @sn, MultiJson.dump(@code)
      end
    }.should.raise(Computer::Invalid)
    .message.should.match /Too many similar paths: book\/\.\.\.\/\*/
  end

end # === describe Code: create ===


