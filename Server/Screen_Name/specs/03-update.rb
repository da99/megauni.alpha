
require './Server/Customer/model'

include Screen_Name_Test

describe 'Screen-Name:' do

  describe ":update" do

    it 'updates screen name' do
      o  = create_screen_name
      c  = o[:c]
      sn = o[:sn]
      name = "updated_#{sn.data[:screen_name]}"
      sn.update screen_name: name

      rec = Screen_Name::TABLE[screen_name: name.upcase]
      rec[:id].should.equal sn.data[:id]
    end # === it

  end # === describe

end # === describe update










