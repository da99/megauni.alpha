require '__rack__'

class Helper_Textile_To_Html

  include FeFe_Test

  context 'Helper: textile_to_html' 

  it 'renders RedCloth textile to html' do
    app.get '/ttt1' do
      textile_to_html(" 
      div(red). Hello
      ")
    end

    get '/ttt1'
    demand_equal last_response.body.strip, '<div class="red">Hello</div>'
  end

  context 'Helper: textile_to_html with "img" tag' 

  it 'renders img tag to valid html img tags.' do
    app.get '/ttt2' do
      textile_to_html(" 
      img(red). /images/sinatra.img
      ")
    end

    get '/ttt2'
    body_parts = last_response.body.split.sort
    target_parts = '<img src="/images/sinatra.img" alt="*" title="*" class="red" />'.split.sort
    demand_equal body_parts, target_parts
  end

  it 'ignores non-numeric characters in w/h dimensions' do
    app.get '/ttt3' do
      textile_to_html("
        img. /images/ime.png
          w 34px h 65
      ")
    end

    get '/ttt3'
    body_parts =last_response.body.split.sort
    target_parts = '<img src="/images/ime.png" alt="*" title="*" width="34" height="65" />'.split.sort
    demand_equal body_parts, target_parts
  end 

  it 'escapes html in alt text.' do
    app.get '/ttt4' do
      textile_to_html("
        img. /images/u.png
          w 30 h 30
          Something <bold>brave</bold>.
      ")
    end

    get '/ttt4'
    body_parts =last_response.body.split.sort
    alt_text = "Something &lt;bold&gt;brave&lt;/bold&gt;."
    target_parts = %~<img src="/images/u.png" alt="#{alt_text}" title="#{alt_text}" width="30" height="30" />~.split.sort
    demand_equal body_parts, target_parts
  end


end
