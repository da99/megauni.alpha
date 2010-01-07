# VIEW views/Club_Control_edit.rb
# SASS /home/da01/MyLife/apps/megauni/templates/English/sass/Club_Control_edit.sass
# NAME Club_Control_edit

div.content! { 
  
  div.club_info! {
    p 'Teaser: {{club_teaser}}'
    p 'Filename: {{club_filename}}'
  }

  div.news! {
    
    mustache 'no_news' do
      p.empty 'No news posted yet.'
    end

    mustache 'news' do
      ul {
        li {
          a("{{title}}", :href=>"{{href}}")
          span ' - '
          a("Edit", :href=>"{{href_edit}}")
        }
      }
    end
    
  }
  
} # === div.content!

partial('__nav_bar')

