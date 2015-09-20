

div.box.New_Chit_Chat! {

  h3 "Post to your message board:"

  div.content {
    form.Create_Chit_Cat!(action: '/Chit_Chat', method: 'POST') {
      div.fields do
        div.field.body { textarea(name: "body", maxlength: "1000") }
        div.field.buttons { button.submit "Send" }
      end # === div.fields
    }
  }

} # === New_Chit_Chat!


