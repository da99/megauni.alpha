
require './Server/Computer/model'

describe "Computer: as-comment-read" do

  before do
    @sn1 = Screen_Name_Test.screen_name 0
    @sn2 = Screen_Name_Test.screen_name 1
    @cc1 = Chit_Chat.create @sn1, "msg #{Time.now.to_i}"
  end

  it "grabs comments in reverse :created_at order" do
    c1 = Comment.create @sn2, @cc1, "msg 1"
    c2 = Comment.create @sn2, @cc1, "msg 2"
    c3 = Comment.create @sn2, @cc1, "msg 3"

    comments = Comment.read @cc1
    comments.map(&:id).should == [c3.id, c2.id, c1.id]
  end

  it "only reads #{Comment::Read_All_Limit} comments" do
    (Comment::Read_All_Limit + 10).times do |i|
      begin
        Comment.create @sn2, @cc1, "msg #{i}"
      rescue Comment::Limit_Reached
      end
    end

    comments = Comment.read @cc1
    comments.size.should == Comment::Read_All_Limit
  end

end # === describe Computer: as-comment-read ===


