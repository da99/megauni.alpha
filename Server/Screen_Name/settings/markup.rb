
title 'Settings for: {{user.screen_name}}'


section :main do
  div.Nav_Bar! {
    a.Go_Home!('Go Back Home', :href=>'/')
  }

  mustache '^bots' do
    red_cloth %^
    <div id="Empty">
      You have not chosen any bots to use.
      Go chose some bots from the list: "/bots":/bots
    </div>
    ^
  end # === ^bots

end # === section :main
