
class ROOT
  class POST < Roda
    plugin :middleware

    route { |r|
      r.get '!:raw_id' do |raw_id|
        HTML.to_html(
          id: raw_id,
          title: "Who invaded: what? when? where?"
        )
      end # === on get
    } # === route

    HTML = Megauni::WWW_App.new {

      use ::MUE

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

      use ::NAV_BAR
      title '{{{html.title}}}'

      h1.^(:title) { '{{{html.title}}}' }

      div.^(:block) {
        div.^(:section) {
          text 'by: unknown'
        }
      }

    } # === WWW_App

  end # === class POST
end # === class ROOT

use ROOT::POST

