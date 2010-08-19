# MAB   ~/megauni/templates/en-us/mab/Members_life.rb
# SASS  ~/megauni/templates/en-us/sass/Members_life.sass
# NAME  Members_life

require 'views/__Base_View_Member_Life'

class Members_life < Base_View

  include Base_View_Member_Life

  def title 
    "The Universe of #{app.env['results.username']}"
  end

  def stream
    compiled_owner_messages :$in=>%w{fact question status buy comment}
  end
  
end # === Members_life 
