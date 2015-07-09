

def_section :Create_Life

section :Create_Life do

  div.box.Create_Life! do

    div.mini_box.my_life {
      h3 "My Life(s):"
      div.content do
        ul.screen_names {
          mustache :screen_names do
            li {
              a("{{screen_name}}", href:"{{href}}")
            }
          end
        }
      end
    }

    div.mini_box.create_life {

      h3 "Create A New Life:"

      div.content do

        form.Create_Screen_Name!(action:"/@", method:"POST") do
          div.fields {
            div.field.screen_name {
              span.label "Screen Name:"
              input(type:"text", value:"", name:"screen_name", maxlength:"40")
            }
          }

          div.buttons { button.submit "Create" }
        end
      end
    }
  end

end # === section Create_Life
