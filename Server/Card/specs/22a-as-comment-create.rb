
require './Server/Computer/model'
require './Server/Screen_Name/specs/helpers'

describe "Computer: as-comment-create" do

  before do
    @sn1 = Screen_Name_Test.list 0
    @sn2 = Screen_Name_Test.list 1
    @cc1 = create_chit_chat @sn1, "msg #{Time.now.to_i}"
  end

  it "raises Comment::Limit_Reached if more than #{Comment::Create_Limit} comments are created" do
    lambda {
      (Comment::Create_Limit + 1).times do |i|
        Comment.create @sn2, @cc1, "msg #{i}"
      end
    }.should.raise(Comment::Limit_Reached)
    .msg.should.match(/Comment limit reached. No more comments can be created./)
  end

end # === describe Computer: as-comment-create ===


