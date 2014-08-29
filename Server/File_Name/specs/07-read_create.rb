
require './Server/File_Name/model'

describe "File_Name: read_create" do

  before do
    File_Name::TABLE.where("id > 1000").delete
  end

  it "create a file_name record if it does not exist" do
    File_Name.read_create("Sky_Monster")
    records = File_Name::TABLE.where(:file_name=>"sky_monster").map { |r|
      r[:file_name]
    }
    records.should == ["sky_monster"]
  end

  it "returns the record of newly created record" do
    r = File_Name.read_create("Sky_Monster_2")
    r.file_name.should == "sky_monster_2"
  end

  it "returns record if it already exists" do
    name = "Sky_Monster_3"
    File_Name.read_create name
    r = File_Name.read_create name
    r.file_name.should == name.downcase
  end

end # === describe File_Name: read_create ===


