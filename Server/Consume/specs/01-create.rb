
require './Server/Consume/model'
require './Server/Screen_Name/specs/helpers'
require './Server/Consume/specs/helpers'

describe "Consume: create" do

  before do
    Consume_Test.delete
    @producer_1 = Screen_Name_Test.list 0
    @producer_2 = Screen_Name_Test.list 1

    @consumer_1 = Screen_Name_Test.list 2
    @consumer_2 = Screen_Name_Test.list 3
  end

  it "ignores duplicates of follows between the same consumer and publication" do
    lambda {
      Consume.create @consumer_1, 'follow', @producer_1
      Consume.create @consumer_1, 'follow', @producer_1
    }.should.not.raise

    records = Consume::TABLE.where(:consumer_id => @consumer_1.id).all
    records.size.should == 1
  end

end # === describe Consume: create ===


