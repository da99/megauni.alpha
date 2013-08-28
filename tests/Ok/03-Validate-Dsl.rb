
require "./tests/helpers"
require "./Server/Ok/model"

class My_Model
  include Ok::Model

  def create new_data
    @new_data = new_data
    validate(:hello).
      set_to("ok dokie")
    self
  end

end

describe ":validate" do

  it "can accept new_data as strings" do
    o = My_Model.create('hello'=>'hi there')
    o.clean_data[:hello].should == 'ok dokie'
  end

  it "can accept new_data as symbols" do
    o = My_Model.create(hello: 'hi there')
    o.clean_data[:hello].should == 'ok dokie'
  end

end # === describe sdff ===
