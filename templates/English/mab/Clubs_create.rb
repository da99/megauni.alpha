# VIEW views/Clubs_create.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/English/sass/Clubs_create.sass
# NAME Clubs_create

div.content! { 
  
  h4 'Create a Club'

  form(:id=>'form_clubs_create', :action=>"/clubs/", :method=>"post") {
    fieldset {
      label 'Title:'
      input :name=>'title', :id=>'create_club_title', :type=>'text', :value=>''
    }
    fieldset {
      label 'Filename:'
      input :name=>'filename', :id=>'create_club_filename', :type=>'text', :value=>''
    }
    fieldset {
      label 'Description:'
      textarea '', :name=>'teaser', :id=>'create_club_teaser'
    }
    div.buttons {
      button 'Save'
    }
  }

  a('See complete list of clubs.', :href=>'/clubs/')
  
} # === div.content!

partial('__nav_bar')

