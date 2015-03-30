
use(

  Cuba.new {

    on get, root do
      res.write mu(:ROOT).to_html(YEAR: Time.now.utc.year, auth_token: 'TEMP')
    end

    if ENV['IS_DEV']
      on('raise-error-for-test') { something }
    end

  } # === Cuba.new

) # === use

mu(:ROOT) {

  mue = mu!(:MUE)

  WWW_App.new {

    var :heading_color       , '#357BB5'
    use mue

    style {

      div.^(:block) {
        float        'left'
      }

    } # === style

    title "megaUNI Homepage"

    div.^(:block).id(:New_Session) {

      h3 "Log-In"

      div.^(:content) {

        form.id(:sign_in).action('/sign-in').method('post') {

          div.^(:fields) {

            div.^(:field, :screen_name) {
              label.for("LOGIN_SCREEN_NAME") { "Screen name:" }
              input('text', "screen_name", "")./
            }

            div.^(:field).^(:passphrase) {
              label.for("LOGIN_PASS_PHRASE") { "Pass phrase:" }
              input('password', "pswd", "")./
            }

            div.^(:field, :buttons) {
              button.^(:submit) { "Log-In" }
            }

          } # --- div.fields
        } # --- form
      } # --- div.content
    } # --- div.box

    div.id(:New_Customer).^(:block) {

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
    } # === div block

    div.^(:block).id(:intro) {

      border '0'
      max_width '200px'

      h1.^(:title) {

        span.^(:main) { "mega" }
        span.^(:sub) {  "UNI" }
      }

      if ENV['IS_DEV']
        p { a.href('/home') { '/home' } }
        p { a.href('/@da99') { '/@da99' } }
        p { a.href('/!4567') { '/!4567' } }
      end

      div.^(:disclaimer) {
        p  {
          raw_text "&copy;"
          text  " 2012-{{num.YEAR}} megauni.com. Some rights reserved."
        }

        p { "All other copyrights belong to their respective owners, who have no association to this site:" }

        p {
          span { "Logo font: " }
          a.href("http://openfontlibrary.org/en/font/otfpoc") {"Aghja" }
        }

        p {
          span  { "Palettes: " }
          a.href("http://www.colourlovers.com/lover/dvdcpd") { "dvdcpd" }
          a.href("http://www.colourlovers.com/palette/154398/bedouin") { "shari_foru" }
        }

      } # === div.disclaimer

    } # div block

  } # === WWW_App.new
} # === mu :FILE_INDEX
