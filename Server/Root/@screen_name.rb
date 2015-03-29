
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

    padding '0'
    margin  '0'

    title '{{{html.screen_name}}}'

    h1 {
      background_color heading_color
      color            '#fff'
      margin_top       '0'
      margin_bottom    '0'
      padding          '0.5em'
     '{{{html.screen_name}}}'
    }

    div.id(:nav_bar) {
      a.href('/') { 'megauni home' }
      a.href('/log-out') { 'Log-Out' }
    }

    div.^(:block) {
      h3 '{{{html.screen_name}}}'
    }

  } # === WWW_App.new
} # === mu :@SCREEN_NAME
