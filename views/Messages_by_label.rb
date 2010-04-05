# MAB   /home/da01tv/MyLife/apps/megauni/templates/English/mab/Messages_by_label.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/English/sass/Messages_by_label.sass
# NAME  Messages_by_label

class Messages_by_label < Base_View

  def title 
    "Messages labeled: #{label}"
  end
  
  def months
    %w{ 8 4 3 2 1 }.map { |month|
      { :text => Time.local(2007, month).strftime('%B %Y'),
        :href=>"/clubs/hearts/by_date/2007/#{month}/" 
      }
    }
  end

  def label
    @app.env['message_label']
  end

  def public_labels
    @public_labels ||= Message.public_labels.map {|label| {:filename => label} }
  end

  def messages
    @app.env['messages_by_label'].map { |mess|
      { 'published_at' => Time.parse(mess['published_at'] || mess['created_at']).strftime(' %b  %d, %Y '),
        'body' => mess['body'],
        'title' => mess['title'],
        'href' => "/mess/#{mess['_id'].sub('message-','')}/"
      }
    }
  end

end # === Messages_by_label 
