
div.box.New_Session! {

  h3 "Log-In"

  div.content {

    form(id:'sign_in', action:'/sign-in', method:'post') {

      div.fields {

        div.field.screen_name {
          label( "Screen name:", for:"LOGIN_SCREEN_NAME")
          input.field.LOGIN_SCREEN_NAME!(type:'text', name:"screen_name", value:"")
        }

        div.field.passphrase {
          label( "Pass phrase:", for:"LOGIN_PASS_PHRASE")
          input.field.LOGIN_PASS_PHRASE!(type:'password', name:"pass_word", value:"")
        }

        div.field.buttons {
          button.submit "Log-In"
        }

      } # --- div.fields
    } # --- form
  } # --- div.content
} # --- div.box
