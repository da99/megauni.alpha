
use(
  Cuba.new {
    on get, root do
      res.write mu(:FILE_INDEX).to_html(YEAR: Time.now.utc.year)
    end

    if ENV['IS_DEV']
      on('raise-error-for-test') { something }
    end
  }
) # === use


mu(:FILE_INDEX) {
  WWW_App.new {

    link.type('text/css').rel('stylesheet').href('/css/vanilla.reset.css')./

    title "megaUNI Homepage"

    div.^(:main) {

      div.^(:sidebar).id(:sidebar) {

        h1.^(:title) {
          span.^(:main) { "mega" }
          span.^(:sub) { "UNI" }
        }

        div.id(:header) {
          p do
            span.^(:about) { "Multi-Life Chat & Publishing" }
            br./
            span { "Coming later this year." }
          end

          p do
            strong { "~ ~ ~" }
          end
        }

        div.id(:footer) {
          p  {
            raw_text "&copy;"
            text  " 2012-{{num.YEAR}} OKdoki.com. Some rights reserved."
          }

          p { "All other copyrights belong to their respective owners." }

          p {
            span { "Logo font: " }
            a.href("http://lenkavomelova.com/") {"Lenka Stabilo" }
          }

          p {
            span { "Life & Website Header font: " }
            a.href("http://openfontlibrary.org/en/font/circus") { "Circus" }
          }

          p {
            span { "Wood Pattern: " }
            a.href("http://subtlepatterns.com/wood-pattern/") { "Alexey Usoltsev" }
          }

          p {
            span { "Ravenna Pattern: " }
            a.href("http://subtlepatterns.com/ravenna/")  { "Sentel" }
          }

          p {
            span  { "Escheresque Pattern: " }
            a.href("http://subtlepatterns.com/?s=Escheresque&submit=Search") { "Ste Patten & Jan Meeus" }
          }

          p {
            span  { "Palettes: " }
            a.href("http://www.colourlovers.com/lover/dvdcpd") { "dvdcpd" }
            a.href("http://www.colourlovers.com/palette/154398/bedouin") { "shari_foru" }
          }

        } # === div.id :footer

      } # div #siderbar

    } # div #main

  } # === WWW_App.new
} # === mu :FILE_INDEX
