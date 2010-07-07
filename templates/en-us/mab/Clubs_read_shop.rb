# VIEW views/Clubs_read_shop.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_shop.sass
# NAME Clubs_read_shop

# div.col.intro! {
# } # div.intro!

div.col.navigate! {
  
  h3 '{{title}}' 
  
  club_nav_bar(__FILE__)

  show_if 'logged_in?' do
    
    div.col.guide! {
      h4 'Stuff you can do here:'
      p %~
        You post your favorite stuff to buy.
      Tell people: 
      ~
      ul {
        li 'where you bought it.'
        li 'how much it cost you.'
        li 'why others should buy it too.'
      }
    }

    div.col.message_create! {
      form_message_create(
        :title => 'Recommend a product:',
        :hidden_input => {
                          :message_model => 'buy',
                          :club_filename => '{{club_filename}}',
                          :privacy       => 'public'
                         }
      )
    }
    
  end # logged_in?


  div.col.club_messages! do
    
    show_if('no_buys?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'buys'
    
  end
  
} # div.navigate!

