
require './Server/Customer/model'

include Customer_Test


describe 'delete_trashed' do

  before do
    @c = find_customer[:c]
  end

  it 'it does not delete Customer records less than 2 days old' do
    Customer::TABLE.
      where(id: @c.id).
      update(trashed_at: Sequel.lit(" #{Okdoki::Model::PG::UTC_NOW_RAW} - interval '70 hours' "))

    Customer.empty_trash

    last = Customer.read_by_id @c.id

    @c.id.should == last.id
  end # === it

  it 'it deletes Customer and Screen-Names' do
    Customer::TABLE.
      where(id: @c.id).
      update(trashed_at: Sequel.lit(" #{Okdoki::Model::PG::UTC_NOW_RAW} - interval '72 hours' "))

    Customer.empty_trash

    lambda {
      Customer.read_by_id @c.id
    }.should.raise(Customer::Not_Found).
      message.
      should.match(/Customer not found./)

    # read screen names
    count = Screen_Name::TABLE.where(owner_id: @c.id).count

    count.should == 0
  end # === it

end # === describe delete


