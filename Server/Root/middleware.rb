
use(

  Cuba.new {

    on get, root do
      # if logged_in?
        # html 'Customer/lifes', {
          # :intro        => "My Account...",
          # :default_sn   => user.screen_names.first.to_public,
          # :screen_names => user.screen_names.map(&:to_public),
          # :sn_all       => user.screen_names.map(&:screen_name).join(', '),
          # :is_owner     => logged_in?
        # }
      # else
        # html 'Okdoki/top_slash', {
          # title: 'OkDoki.com',
          # YEAR: Time.now.year
        # }
      # end

      res.write mu(:FILE_INDEX).to_html(YEAR: Time.now.utc.year, auth_token: 'TEMP')
    end

    if ENV['IS_DEV']
      on('raise-error-for-test') { something }
    end

  } # === Cuba.new

) # === use


mu(:FILE_INDEX) {
  WWW_App.new {

    link.href('/css/vanilla.reset.css')./
    link.href('/css/fonts.css')./
    link.href('/css/otfpoc.css')./


    style {
      background_color "#f5f5f5"
      a._hover {
        color '#C0002C'
      }
      div.^(:section) {
        border_right '1px dashed #C7C7C7'
        width '30%'
        float 'left'
        padding '0 1em 0 0'
      }
    }

    title "megaUNI Homepage"

    div.^(:section) {
      div.id(:New_Customer).^(:box) {
        h3 "Create a New Account"
        div.^(:content) {

          form.id(:create_account).action('/user').method('post') {

            div.^(:fields) {

              div.^(:field, :screen_name) {
                label.for(:NEW_CUSTOMER_SCREEN_NAME) { "Screen name:" }
                input(:text, "screen_name","")./
              }

              div.^(:field, :pswd) {
                label.for(:NEW_CUSTOMER_PASS_PHRASE) {
                  span.^(:main) { "Pass phrase" }
                  span.^(:sub)  { " (for better security, use spaces and words)" }
                  span.^(:main) { ":" }
                }
                input(:password, :pswd, "")./
              }

              div.^(:field).^(:confirm_pass_phrase) {
                label.for(:NEW_CUSTOMER_CONFIRM_PASS_PHRASE) {
                  span.^(:main) { "Re-type the pass phrase:" }
                }
                input(:password, :confirm_pass_word, "")./
              }


              div.^(:buttons) {
                # input(type: 'hidden', name: "_csrf", value: "{{_csrf}}")
                button.^(:submit) { "Create Account" }
              }

            } # --- div.fields

          } # --- form

        } # --- div.content
      } # --- div.box
    } # === div section

    div.^(:main, :section) {

      div.^(:sidebar).id(:sidebar) {

        h1.^(:title) {
          font_family 'AghjaMedium'
          font_weight 'normal'
          font_style  'normal'
          color       '#357BB5'
          margin      '0.5em 0'

          span.^(:main) { "mega" }
          span.^(:sub) {  "UNI" }
        }

        div.id(:footer) {
          style {
            color '#B0B0B0'
            p {
              margin '0 0 0.5em 0'
            }
          }

          p  {
            raw_text "&copy;"
            text  " 2012-{{num.YEAR}} megauni.com. Some rights reserved."
          }

          p { "All other copyrights belong to their respective owners." }

          p {
            span { "Logo font: " }
            a.href("http://openfontlibrary.org/en/font/otfpoc") {"Aghja" }
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
