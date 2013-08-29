
def_section :Bot_Create

section :Bot_Create do

  div.New_Bot!(:class => "box {{has_bots}}") do
    div.setting { a.on('Show', href:"#show") }

    h3 "Create a Bot"

    div.content do

      div.list {
        mustache :bots do
          a('{{name}}', href:"{{href}}")
        end
      }

      form.Bot_Create!(action:"/Bot", method:"POST") {
        div.fields {
          div.field.sub_sn {
          label('Screen Name:', 'for'=>"NEW_BOT_SCREEN_NAME")
          input.NEW_BOT_SCREEN_NAME!(name:"sub_sn", type:"text")
        }
        }
        div.buttons {
          span_as()
          button.submit "Create"
        }
      } # === form.Bot_Create!

    end # === div.content
  end # === div.New_Bot!
end # === section Bot_Create
