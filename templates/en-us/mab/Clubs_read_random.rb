# VIEW views/Clubs_read_random.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_random.sass
# NAME Clubs_read_random

div.col.intro! {
  
  h3 '{{title}}' 
  
  show_if 'logged_in?' do
    
    form_message_create(
      :title => 'Post a random thought:',
      :hidden_input => {
                        :message_model => 'random',
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?

} # div.intro!

div.col.navigate! {
  
  club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_random?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'random'
    
  end

} # div.navigate!