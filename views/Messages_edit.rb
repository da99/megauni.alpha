# MAB   /home/da01tv/MyLife/apps/megauni/templates/English/mab/Messages_edit.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/English/sass/Messages_edit.sass
# NAME  Messages_edit

class Messages_edit < Base_View

  def title 
    'Edit: ' + (mess.data.title || mess.data._id)
  end
  
  def mess_href
    @cache['mess_href'] ||= File.join('/', mess.data._id.sub('message-', 'mess/'), '/')
  end

  def mess_data
    @cache[:mess_data] ||= begin
                             hash = mess.data.as_hash
                             hash[:title] ||= nil
                             hash
                           end
  end

  def mess
    @app.env['results.message']
  end

  def mess_id
    mess.data._id
  end
  
end # === Messages_edit 
