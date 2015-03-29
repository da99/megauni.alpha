
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

  WWW_App.new {

    use mue

    style {
      h1 {
        color '#000'
      }

      div.^(:block) {
        max_width '500px'
        width     'auto'
        border '0'

        h3 {
          color '#000'
        }

        div.^(:item) {
          background_color '#fff'
          padding '0 1em 1em 1em'
          margin  '1em'
          border  "1px dashed #D5D5D5"
          color   '#3d3d3d'
          border_radius '5px'
          max_width  '600px'
        }
      }

    } # === style

    padding '0'
    margin  '0'

    title '{{{html.screen_name}}}'

    h1 {
      background_color '#000'
      color            '#fff'
      margin_top       '0'
      margin_bottom    '0'
      padding          '0.5em'
     '{{{html.screen_name}}}'
    }

    div.id(:nav_bar) {
      style {
        a._link {
          color '#000'
        }
        a._visited {
          color light_text_color
        }
        a._hover {
          color '#fff'
        }
      }
      a.href('/') { 'megauni home' }
      a.href('/log-out') { 'Log-Out' }
    }

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
