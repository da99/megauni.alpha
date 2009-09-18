save_to('title') { 
  if app_vars[:news_tag].nil?
    "Tag not found."
  else
    app_vars[:news_tag][:filename]
  end
}


partial('__nav_bar')


div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  
  h2( @title.gsub('_', ' ') )
  
  if app_vars[:news].empty?
    div.heart_link {
      h4 '---'
      div.body {
        'No heart links found.'
      }
    }
  else
    app_vars[:news].each do |post|
      div.heart_link {
       
       div.info {
        span.published_at post[:published_at].strftime('%b  %d, %Y')
        a.permalink('PermaLink', :href=>"/news/#{post[:id]}/")
       }
       h4 post[:title]
       div.body { post.body_html }
      }
    end
  end
  
} # === div.content!



