
new_middleware {
    on get do
      on '!:raw_id' do |raw_id|
        res.write POST_HTML.to_html(
          id: raw_id,
          title: "Who invaded: what? when? where?"
        )
      end
    end # === on get
} # === Cuba.new



POST_HTML = Megauni::WWW_App.new {

    use constant(:MUE)

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

    use constant(:NAV_BAR)
    title '{{{html.title}}}'

    h1.^(:title) { '{{{html.title}}}' }

    div.^(:block) {
      div.^(:section) {
        text 'by: unknown'
      }
    }

  } # === WWW_App
