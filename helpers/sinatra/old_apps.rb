before {
    
  if request.host =~ /busynoise/i && request.path_info == '/'
    redirect('/egg')
  end
  
  [:busynoise, :myeggtimer, :megahtml, :newsprint, :bigdeadline, :bigstopwatch].each { |name|
    if request.host =~ /#{name}/i && ['/', '/egg', '/eggs', '/egg/', '/eggs/'].include?(request.path_info)
      halt show_old_site( name, true )
    end
  }

  # If .html file does not exist, try chopping off .html.
  # This is mainly for backwards compatibility with surferhearts.com.
  if request.path_info =~ /\.html?\z/ && !Pow('public', request.path_info).file?
    redirect( request.path_info.sub( /\.html?\z/, '') )
  end

} # === before

get '/bigstopwatch/?' do
  show_old_site(:bigstopwatch, true)
end

helpers {

  def show_old_site(name, show_moving = false)
  
    page_name = show_moving ? 'moving' : 'index'
  
    case name
    
      when :busynoise, :busy_noise
        Pow("public/busy-noise/#{page_name}.html").read
      
      when :myeggtimer, :my_egg_timer
        Pow("public/my-egg-timer/#{page_name}.html").read
      
      when :megahtml, :newsprint, :bigdeadline, :bigstopwatch
        dot_domain = request.host.sub('www.', '').sub('.', ' [dot] ')
        main_domain = request.host.sub('www.', '')
        %~
          <html>
            <head>
              <title>Learn HTML</title>
              <meta name="verify-v1" content="Blj1lh0s7UYhIw92PuNfg6EJzZOrUGSZ3Zj4G+GWOlg=" />
              <style type="text/css">


              p { margin: 0 ; }
              body {
                font-family: helvetica, sans-serif;
              }
              a:link, a:visited, a:hover, a:active {
                font-weight: bold;
                padding: 0 4px;
              }
              a:hover {
                background: #D50015;
                color: #fff;
              }
              
              
              li {
                padding-bottom: 10px
              }
              </style>
            </head>
            <body>
              <p>This domain for sale. Contact <span id="email">sales [at] #{dot_domain}</span>
              <script type="text/javascript">
              <!--
                document.getElementById('email').innerHTML = '<a hr' + 'ef="mai' + 'lto:s' + 'ales' + '@' + '#{main_domain}">' + 'sales' + '@' + '#{main_domain}</a>'
              //-->
              </script>
            </body>
          </html>
        ~        
      else
        not_found
    end
    
    
    
  end # === show_old_site
} # === 



