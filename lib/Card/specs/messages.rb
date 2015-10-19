# controls/Messages.rb

describe :Control_Messages_Read do

  it 'render /mess/4c64a6bfb158266233000004/ for anyone' do
    get "/mess/4c64a6bfb158266233000004/"
    assert_equal 200, last_response.status
  end

  it 'render a message posted to a life club' do
    href = "/mess/4c34b7fca58e0c3c07000001/"
    get href
    assert_equal 200, last_response.status
  end

end # === class Test_Control_Messages_Read
