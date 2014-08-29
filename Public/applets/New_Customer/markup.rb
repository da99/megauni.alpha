
div.box.New_Customer! {
  h3 "Create a New Account"
  div.content {

    form(id: 'create_account', action: '/user', method: 'post') {

      div.fields {


        div.field.screen_name {
          label("Screen name:", for: "NEW_CUSTOMER_SCREEN_NAME") 
          input.field.NEW_CUSTOMER_SCREEN_NAME!(type:'text', name:"screen_name", value:"")
        }

        div.field.pass_phrase {
          label(for:"NEW_CUSTOMER_PASS_PHRASE") {
            span.main "Pass phrase"
            span.sub  " (for better security, use spaces and words)"
            span.main ":"
          }
          input.field.NEW_CUSTOMER_PASS_PHRASE!(type:'password', name:"pass_word", value:"")
        }

        div.field.confirm_pass_phrase {
          label(for:"NEW_CUSTOMER_CONFIRM_PASS_PHRASE") {
            span.main "Re-type the pass phrase:"
          }
          input.field.NEW_CUSTOMER_CONFIRM_PASS_PHRASE!(type:'password', name:"confirm_pass_word", value:"")
        }


        div.buttons {
          # input(type: 'hidden', name: "_csrf", value: "{{_csrf}}")
          button.submit "Create Account"
        }

      } # --- div.fields

    } # --- form

  } # --- div.content
} # --- div.box





        # //- div.field.email
          # //- label
            # //- span.main Email:
            # //- span.sub  (in case you forget your password)
          # //- input.field(type='text', name="email", value="work...")

