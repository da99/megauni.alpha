
require './Server/Consume/model'

describe "Consume: as-notify-update update_last_read_at" do

  before do
    Notify::TABLE.delete
    @sn1 = Screen_Name_Test.screen_name 0
    @sn2 = Screen_Name_Test.screen_name 1
    @sn3 = Screen_Name_Test.screen_name 2
    @sn4 = Screen_Name_Test.screen_name 3
  end

  it "sets :last_read_at to NOW()" do
    n1 = Notify.create_or_update @sn1, @sn4, "body 1"
    Notify.update_last_read_at @sn1, @sn4
    row = Notify::TABLE.first

    row[:last_read_at].to_s.should
    .match(/\d{4}-\d\d-\d\d \d\d:\d\d:\d\d -\d+/)
  end

end # === describe Consume: as-notify-update ===


