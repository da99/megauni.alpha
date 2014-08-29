
title '{{title}}'

section :js_templates do
  div.screen_name "{{screen_name}}"
  div.empty.chit_chat_list "
    No messages posted.
    You may post up to 111 messages on your message board.
    Old ones will be deleted to make room for new ones.
  "
end

section :main do

  Nav_Bar!

  div.Me! do

    partial __FILE__, "chit_chat/markup.list.rb"

  end # === div.Me!

  div.Sidebar! {

    div.Me_Intro! {
      div.the_life_of "The life of..."
      h3.name         "{{screen_name}}"
    }

    partial __FILE__, "chit_chat/markup.new.rb"

  } # === Sidebar!

end # === section :content

