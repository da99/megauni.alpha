class Inspect_Control
  
  include Base_Control

  path '/inspect'

  get '/list' do
    file_contents = File.read(File.expand_path(__FILE__)).split("\n")
    end_index     = file_contents.index('__' + 'END' + '__')
    
    template :html
  end
  
  get '/request' do
    if not Uni_App.development?
      not_found "/request only allowed in :development environments."
    end
    
    render :text, "<pre>" + request.env.keys.sort.map { |key| 
      key.inspect + (' ' * (30 - key.inspect.size).abs) + ': ' + request.env[key].inspect 
    }.join("<br />") + "</pre>"
  end
  
end # === Request_Bunny
