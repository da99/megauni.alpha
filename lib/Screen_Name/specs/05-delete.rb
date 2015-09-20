
include Screen_Name_Test

Screen_Name::TABLE.update(:trashed_at=>nil)

describe ':empty_trash' do


  it 'does not delete screen-name records of less than 3 days old' do
    o = create_screen_name
    o[:sn].trash

    Screen_Name.empty_trash

    updated = read_screen_name_record(o)
    updated[:id].should.equal o[:sn].data[:id]
  end # === it

  it 'it deletes screen-name record of more than 3 days old' do
    o = create_screen_name
    o[:sn].trash

    Screen_Name::TABLE.
      where(id: o[:id]).
      update(trashed_at: Sequel.lit("trashed_at - interval '72 hours'"))

    Screen_Name.empty_trash
    read_screen_name_record(o).should.equal nil
  end # === it

end # === describe delete

