
use(

  Cuba.new {

    on get, '@:raw_name' do |raw_name|
      res.write mu(:@SCREEN_NAME).to_html(
        :screen_name => raw_name
      )
    end # === on get

  } # === Cuba.new

); # === use


mu(:@SCREEN_NAME) {

  mue = mu! :MUE
  nav_bar = mu! :NAV_BAR

  WWW_App.new {

    use mue

    style {

      body {
        padding 0
        margin  0
      }

      div.^(:block) {
        max_width '500px'
        width     'auto'
        border    0
      }

    } # === style

    title '{{{html.screen_name}}}'

    h1 {
      background_color black
      color            white
      margin_top       '0'
      margin_bottom    '0'
      padding          '0.5em'
     '{{{html.screen_name}}}'
    }

    use nav_bar

    div.^(:block) {

      div.^(:item) {
        h3 'Secret Compliment'
        div.^(:item_content) {
          div "I think ... and ... and ...."
        }
      }

    } # === div.block

  } # === WWW_App.new
} # === mu :@SCREEN_NAME
