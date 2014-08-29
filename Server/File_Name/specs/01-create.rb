
require './Server/File_Name/model'

describe "File_Name: create" do

  it "raises Invalid if record already exists" do
    lambda {
      File_Name.create "one"
      File_Name.create "one"
    }.should.raise(File_Name::Invalid)
    .message.should.match /already exists/
  end

  it "standardizes the name" do
    name = "One_Two_Three_#{rand(100)}"
    File_Name.create(name).file_name.should == name.downcase
  end

end # === describe File_Name: create ===


