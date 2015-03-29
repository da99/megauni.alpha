
use(

  Cuba.new {
    on get do
      on '!:raw_id' do |raw_id|
        res.write mu(:POST).to_html(
          id: raw_id
        )
      end
    end # === on get
  } # === Cuba.new

); # === use


mu(:POST) {
  mue = mu! :MUE

  WWW_App.new {
    use mue
    title 'POST: {{{html.id}}}'
    div.^(:block) {
      h3 'ID: {{{html.id}}}'
      div.^(:section) {
        text 'by: unknown'
      }
    }
  } # === WWW_App
} # === mu :POST
