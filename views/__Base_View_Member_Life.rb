# MAB   ~/megauni/templates/en-us/mab/Members_life.rb
# MAB   ~/megauni/templates/en-us/mab/Members_life_e.rb
# MAB   ~/megauni/templates/en-us/mab/Members_life_qa.rb
# MAB   ~/megauni/templates/en-us/mab/Members_life_status.rb
# 
# SASS  ~/megauni/templates/en-us/sass/Members_life.sass
# SASS  ~/megauni/templates/en-us/sass/Members_life_e.sass
# SASS  ~/megauni/templates/en-us/sass/Members_life_qa.sass
# SASS  ~/megauni/templates/en-us/sass/Members_life_status.sass
# 
# CONTROL ~/megauni/controls/Members.rb
#
# NAME  Member_Life


module Base_View_Member_Life

  def life_club_href
    "/life/#{username}/"
  end

  def username
    app.env['results.username']
  end
  
  def owner
    app.env['results.owner']
  end

  def owner?
    current_member == owner
  end

  def owner_username_id
    @cache['username_id'] ||= app.env['results.owner'].username_hash.index(username)
  end

  def username_id
    owner_username_id
  end

  def compiled_owner_messages model
    @cache["mess.#{model}"] ||= begin
                                  compile_messages(Message.public(:owner_id=>owner_username_id, :message_model=>model))
                                end
  end

end # === Base_View_Club