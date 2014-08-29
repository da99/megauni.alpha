
require './Server/File_Name/model'

describe "File_Name: read" do

  it "returns a File_Name object" do
    name = "label_#{rand(10000)}"
    File_Name.create(name)
    File_Name.read(name).file_name.should == name
  end

  it "raises File_Name::Invalid if name contains spaces" do
    name = "label something"
    lambda {
      File_Name.read(name)
    }.should.raise(File_Name::Invalid)
    .message.should.match /label something/
  end

  it "raises File_Name::Not_Found if record does not exist" do
    lambda {
      File_Name.read("not_heere")
    }.should.raise(File_Name::Not_Found)
    .message.should.match /not_heere/
  end

end # === describe File_Name: read ===


