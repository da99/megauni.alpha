# controls/Base_Control.rb
require 'tests/__rack_helper__'

class Cafes
  include Base_Control
  
  top_slash

  get :symbol, :STRANGER do
    render :text, action.inspect
  end

  get "/control/name", :STRANGER do
    render :text, "#{control.class}: #{control}"
  end

  path '/subs' 

  get :symbol, :STRANGER do
    render :text, "PATH INFO: #{request.path_info}"
  end
  
  get '/target', :STRANGER do
    pass
    render :text, "Target"
  end

  get '/target', :STRANGER do
    render :text, "Final Target"
  end

end # === class Cafes

class Test_Base_Control < Test::Unit::TestCase

  must 'set control name to class of control' do
    get '/control/name/' 
    assert_equal "Class: Cafes", last_response.body
  end

  must 'set the action name to the path, if path is a symbol: get(:path, :STRANGER)' do
    get '/symbol/'
    assert_equal ":symbol", last_response.body
  end
  
  must 'combine path with base path: path "/sub-path" ' do
    get '/subs/symbol/'
    assert_equal "PATH INFO: /subs/symbol/", last_response.body
  end

  must 'allow render after using :pass' do
    get '/subs/target/'
    assert_equal 'Final Target', last_response.body
  end

end # === class Test_Control_Lifes_Read
