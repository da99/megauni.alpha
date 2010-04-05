# MAB   /home/da01tv/MyLife/apps/megauni/templates/English/mab/Clubs_by_id.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/English/sass/Clubs_by_id.sass
# MODEL models/Club.rb
# CONTROL controls/Clubs.rb
# NAME  Clubs_by_id

class Clubs_by_id < Base_View

  def title 
    @app.env['results.club'].data.title
  end

  def club
    @app.env['results.club']
  end
  
  def months
    %w{ 8 4 3 2 1 }.map { |month|
      { :text => Time.local(2007, month).strftime('%B %Y'),
        :href=>"/clubs/hearts/by_date/2007/#{month}/" 
      }
    }
  end

  def club_title
    club.data.title
  end

  def club_filename
    club.data.filename
  end

  def public_labels
    @public_labels ||= Message.public_labels.map {|label| {:filename => label} }
  end

  def messages_latest
    @cache['results.messages_latest'] ||= begin
                                              @app.env['results.messages_latest'].map { |doc|
                                                doc['compiled_body'] = auto_link(doc['body'])
                                                doc['href'] = "/mess/#{doc['_id'])}/"
                                                doc
                                              }
                                            end
  end
  
end # === Clubs_by_id 
