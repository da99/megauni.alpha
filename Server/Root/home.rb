

# NOTE: I realize I have to find a better
# way of allowing special cars in the URLS
# because I hate monkey patches:
class Da99_Rack_Protect
  class Allow_Only_Roman_Uri
    remove_const :INVALID
    const_set :INVALID, /[^a-zA-Z0-9\_\-\/\.\?\!\@\*\=]+/
  end
end

class HOME < Roda

  plugin :middleware

  route do |r|
    r.get 'home' do
      HTML.to_html(auth_token: 'TEMP')
    end
  end

  HTML = Megauni::WWW_App.new {
    use ::MUE

    style {
      div.^(:block) {
        min_width '300px'
      }
      div.id(:post) {
        border '0'
      }
    }

    div.^(:block) {
      h3 'Global:'
    } # === div.block

    div.^(:block) {
      h3 'Latest:'
    } # === div.block

    div.id(:post).^(:block) {
      h3 'Post:'
    } # === div.block

    title 'Latest'

  } # === WWW_App

end # === HOME < Roda

use HOME

__END__
# if logged_in?
# html 'Customer/lifes', {
# :intro        => "My Account...",
# :default_sn   => user.screen_names.first.to_public,
# :screen_names => user.screen_names.map(&:to_public),
# :sn_all       => user.screen_names.map(&:screen_name).join(', '),
# :is_owner     => logged_in?
# }
# end



