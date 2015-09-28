

title '{{intro}} {{sn_all}}'

applet("Create_Life")

section :js_templates do
  li.screen_name {
    a.name('', href:'{href}')
  }
end

section(:main)  {

  Nav_Bar!

  #//- ===========================================================
  div.Logo! {
    span.wat_wat "My Account @ "
    span.main "ok"
    span.sub "doki"
  }

  # //- ===========================================================
  div.col.Interact! {

    section :Create_Life

  }

  # //- ===========================================================
  div.col.Msgs! {
    div.Headlines!
  }

} # === main



