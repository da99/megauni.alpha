
describe 'Link.create' do

  it "creates a link" do
    l = Link.create(owner_id: 1, type_id: 1, asker_id: 1, giver_id: rand(10000))
    l.data[:id].should.is_a Numeric
  end

  it "throws :not_allowed if :POST_TO_SCREEN_NAME is made by SN/Customer lacking a :ALLOW_TO_LINK"
  it "throws :not_allowed if linker is linking non-owned computers"

end # === describe 'Link.create'
