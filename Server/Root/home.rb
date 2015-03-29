use(

  Cuba.new {
    on get do
      on 'home' do
        res.write mu(:HOME).to_html(auth_token: 'TEMP')
      end # === home
    end # === on
  } # === Cuba.new

); # === use

mu(:HOME) {

  mue = mu!(:MUE)
  WWW_App.new {
    use mue

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
} # === mu :HOME_STACHE
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


