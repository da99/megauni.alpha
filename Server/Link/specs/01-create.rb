
describe 'Link.create' do

  it "creates a link" do
    l = Link.create(owner_id: 1, type_id: 1, left_id: 1, right_id: rand(10000))
    l.data[:id].should.is_a Numeric
  end

end # === describe 'Link.create'
