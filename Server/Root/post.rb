
use(

  Cuba.new {
    on get do
      on '!:raw_id' do |raw_id|
        res.write mu(:POST).to_html(
          id: raw_id,
          title: "Who invaded: what? when? where?"
        )
      end
    end # === on get
  } # === Cuba.new

); # === use


mu(:POST) {
  mue = mu! :MUE
  nav_bar = mu! :NAV_BAR

  WWW_App.new {
    use mue

    style {
      body {
        padding 0
        margin  0
      }

      h1.^(:title) {
        padding     '0 0 0 0.5em'
        font_size   'xx-large'
      }
    } # === style

    use nav_bar
    title '{{{html.title}}}'

    h1.^(:title) { '{{{html.title}}}' }

    div.^(:block) {
      div.^(:section) {
        text 'by: unknown'
      }
    }

  } # === WWW_App
} # === mu :POST
