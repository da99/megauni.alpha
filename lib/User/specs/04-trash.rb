
require './Server/Customer/model'

include Customer_Test

describe 'trash' do

  before do
    @c = find_customer[:c]
  end

  it 'it updates Customer trashed_at date' do

    c = Customer.read_by_id @c.id
    c.trash

    updated = Customer.read_by_id @c.id
    assert within_secs(2), updated.data[:trashed_at]

  end # === it

end # === describe trash




