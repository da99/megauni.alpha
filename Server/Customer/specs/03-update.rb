
require './Server/Customer/model'

include Customer_Test

describe 'update:' do

  before do
    @c = find_customer[:c]
  end

  it 'updates Customer email in instance' do
    new_email = 'new-email@i-hate-all.com'
    @c.update  email: new_email
    assert :==, new_email, @c.data[:email]
  end # === it

  it 'updates Customer email in db' do
    new_email = 'new@i-hate-all.com.something'
    @c.update(email: new_email)

    last = Customer.read_by_id(@c.id)
    assert :equal, new_email, last.data[:email]
  end # === it

end # === describe update







