# tests/Test_Control_Hellos.rb
# tests/Test_Control_Hellos_Mobile.rb
#
class Hellos
  include Base_Control

  top_slash 

  get '/', :STRANGER do
    action :list
    cache_for 5
    template :html
  end

  get :salud, :STRANGER do
    template :html
  end

  redirect('/*robots.txt').to('/robots.txt')
  redirect('/blog').to('/news')
  redirect('/about').to('/help')
  redirect {
    from *(%w{ /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/ })
    to '/salud/m/'
  }

  get :help, :STRANGER do
    template :html
  end

  get '/sitemap.xml', :STRANGER do
    action :sitemap
    template :xml
  end

  get '/rss.xml', :STRANGER do
    action :rss
    template :xml
  end
  
  get '/*beeping.*', :STRANGER do
    exts = ['mp3', 'wav'].detect  { |e| e == params['splat'].last.downcase }
    not_found if !exts
    redirect "http://megauni.s3.amazonaws.com/beeping.#{exts}" 
  end

  def GET_google_verify
    render_text_plain "googleb9009ed100e7fc31"
  end

end # === Hello
