# controls/Hellos.rb


describe :Control_Hellos_Mobile do

  it 'redirects /m to homepage' do
    get '/m'
    redirects_to '/'
  end

  it 'redirects /salud/m to /salud' do
    get '/salud/m'
    redirects_to '/salud', 303
  end

  it 'redirects /help/m to /' do
    get '/help/m' 
    redirects_to '/', 303
  end

  salud_urls = %w{ /saludm /saludmobi /saludiphone /saludpda }
  it "redirects the following to /salud: #{salud_urls.join " "}" do
    salud_urls.each { |url|
      get url
      redirects_to '/salud'
    }
  end

end # === class Test_Control_Hellos_Mobile
