
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

    title '{{{html.screen_name}}}'
    div.^(:block) {
      h3 '{{{html.screen_name}}}'
    }
  }
} # === mu :@SCREEN_NAME
