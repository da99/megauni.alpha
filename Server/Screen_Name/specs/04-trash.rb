
include Screen_Name_Test

describe "Screen_Name" do

  describe 'trash' do

    it "it updates screen-name's :trashed_at to now @ UTC" do
      o = create_screen_name
      o[:sn].trash
      updated = read_screen_name_record(o)
      updated[:trashed_at].should.be within_secs(3)
    end # === it

  end # === describe trash ===

  describe 'untrash' do

    it "it updates screen-name's :trashed_at to nil" do
      o = create_screen_name
      o[:sn].trash
      o[:sn].untrash
      new_sn = read_screen_name_record(o)
      new_sn[:trashed_at].should.equal nil
    end # === it

  end # === describe trash ===

end # === describe Screen_Name ===


