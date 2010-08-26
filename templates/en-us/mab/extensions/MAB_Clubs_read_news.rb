# MAB     ~/megauni/templates/en-us/mab/Clubs_read_news.rb
# VIEW    ~/megauni/views/Clubs_read_news.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_news.sass
# NAME    Clubs_read_news
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_news_STRANGER
end

module MAB_Clubs_read_news_MEMBER
end

module MAB_Clubs_read_news_INSIDER
end

module MAB_Clubs_read_news_OWNER
  def publisher_guide
        guide( 'Stuff you can do here:' ) {
          p %~
            Post only important news. 
          Examples:
          ~
          ul {
            li 'Your plane landed in Dallas.'
            li 'You got a job demotion.'
            li 'You broke up with your dog walker.'
            li 'You got arrested... again.'
          }
        }
  end
end


module MAB_Clubs_read_news
  
  def messages_list
    'news'
  end

  def post_message
    super {
      css_class  'col'
      title  'Post news:'
      input_title 
      hidden_input(
        :message_model => 'news', 
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end

  def about
    super('* * *', ' - - - ')
  end
  
  def publisher_guide
    p "No news posted yet."
  end

end # === module MAB_Clubs_read_news
      
