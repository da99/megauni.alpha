
require './Server/Computer/model'
require './Server/Screen_Name/specs/helpers'
require './Server/Computer/specs/helpers'

require "json"

describe "Computer: as-message-create" do

  before do
    Computer_Test.delete_all

    @sn1 = Screen_Name_Test.list 0
    @sn2 = Screen_Name_Test.list 1
    @code = [
      "class",   ["Okdoki/Message"],
      "privacy", ["public"],
      "body",    ["Hello 1"]
    ]
  end

  it "deletes old messages if message limit reached" do
    34.times { |i|
      Computer.create @sn1, @code.to_json
    }
    Computer::TABLE.where(:owner_id=>@sn1.id).count.
      should == 33
  end

  it "raises Invalid if body is empty" do
    @code.pop
    @code.push [""]

    lambda {
      Computer.create @sn1, @code.to_json
    }.should.raise(Computer::Invalid).
    message.should.match /Body is required/
  end

  it "raises Invalid if body has too many chars" do
    @code.pop
    @code.push [("a " * 1000)]

    lambda {
      Computer.create @sn1, @code.to_json
    }.should.raise(Computer::Invalid).
    message.should.match /Too many charactors: \d\d over the limit/
  end

  it "deletes comments from deleted old Computers" do

    comment = nil
    34.times do |i|
      msg = Computer.create @sn1, @code.to_json
      if i = 0
        comment = Computer.create @sn2, [
          "class",   ["Okdoki/Comment"],
          "message", [msg.id.to_s],
          "body", ["my comment!"]
        ].to_json
      end
    end

    Comment::TABLE[:id=>comment.id]
    .should == nil
  end

end # === describe Computer: as-message-create ===


