    # link.href "../../../Public/css/_common"

    # =====================================================
    # =====================================================

    style {
      # /* [> background: #fff url("http://megauni.s3.amazonaws.com/bg.gif") repeat -125px 0; <] */
      # /* background: #fff url('http://megauni.s3.amazonaws.com/bg_overlay.gif') repeat -37px 0 */

      sidebar_width   = '300px'
      write_col_width = '300px'
      box_margin      = '10px'

      def background_size *args
        _moz_background_size    *args
        _webkit_background_size *args
        _o_background_size      *args
        _ms_background_size     *args
        background_size         *args
      end

      body {
        background_color "transparent"
        padding "0"
      }

      a._link / a._visited {
        border "0"
        text_decoration "underline"
      }
      a._hover {
        text_decoration "none"
      }

      #intro
        background "#000"
        color "#E1EEFF"
        padding "0"


      div.intro
        background "#000"
        color "#E1EEFF"
        padding "0"

      h1.title
        text_shadow "black 0.1em 0.1em 0.1em"
        font_family "Libertinage"
        font_weight "400"
        font_size "24pt"
        text_align "center"
        margin "0 0 0 0"
        line_height "1.5"
        padding "10px 0 7px 0"
        span
          &.main
            color           "#e5e5e2"
            text_transform  "lowercase"

          &.sub
            font_weight     "bold"
            color           "$pink"
            color           "#DE5787"
            text_transform  "uppercase"


      span
        &.about
          color        "$orange"
          font_weight  "normal"
          font_size    "110%"
          font_style   "italic"
        ul.nav_bar
          text_align "left"
          padding_top "100px"
        input
          width "90%"

      div.form
        margin "0 10px"

        div.form h2
          color "$dark_blue"

        div.form a.cancel
          margin_left "10px"


      #show_sign_in
        padding "0"
        margin "0"



      #header, #footer
        background "#000"
        background "$glass_black"
        text_align  "center"
        text_align "center"
        p
          max_width "400px"
          margin "0 auto"
        strong
          background "#185DAD"
          color "#fff"

      #header
        padding        "10px 0 10px 0"
        margin         "0px 0 0 0"
        border_radius  "0"
        color          light_blue

        h2
          font_family  "serif"
          font_size    "250%"
          font_style   "italic"
          font_weight  "normal"
          color        "#FF721A"
          padding      "0"
          margin       "0"
          line_height  "1.3em"

        strong
          background "#185DAD"
          color "#fff"

        p
          margin "0"
          padding "0 30px"




      #footer
        margin         "10px 0 0 0"
        border_radius  "0 0 5px 0"
        padding        "8px 0 10px 0"
        font_size      "80%"
        color          "lighten($downlight_on_black, 20%)"
        p
          margin "0"
          padding "0"
          line_height "16px"


      #keyword
        margin_top "0"
        padding_top "20px"
        padding_bottom "30px"

        div.label
          background "transparent"
          color "#B7D850"
          font_weight "bold"
          padding "0"
          display "block"
          padding_right "25px"
          padding_bottom "4px"


        input
          font_family "monospace"
          font_weight "bold"
          margin "0px"


      #blocks
        overflow "auto"
        padding "0"
        float "left"


        div.box
          float "left"
          width "300px"
          margin "5px 5px 10px 5px"


          #latest div.body
            padding_top "0"

          #create_screen_name
            input[type='text']
              width "250px"


      #trash_e
        div.buttons
          text_align "center"


      #contacts
        div.contact
          padding "0 0 5px 0"
        span.value
          font_size "90%"


      div.item
        padding "9px 0 4px 0"
        border "1px dashed red"
        border_width "0 0 1px 0"

        span.time
          font_size "70%"
          font_style "italic"
          color "#5F7483"
          line_height "15px"

        span.value
          display "block

        span.label
          text_transform "lowercase"
          font_size "70%"
          font_weight "normal"

        span.by
          font_size "70%"
          font_style "italic"
          color "#5F7483"
          line_height "15px"


      a.author, a.read_more
        font_size "80%"


      a.author
        text_transform "none"


      # Forms =======================================

      form
        div.success
          border "0"
          color "$yellow_med"

      input[type="text"] / input[type="password"] / textarea
        background "#ececec"

      #forms
        margin      "10px 0 0 0
        text_align  "center
        background  "$glass_black

        div.tabs
          padding "7px 0
          a
            &.selected
              text_decoration  "none
              background "$light_blue
              border_radius "2px 2px 0 0
              color "$black
              padding_bottom "9px
              &:hover
                background "$light_blue
                color "$black
          span.or
            font_size   "90%
            font_style  "italic
            color       "$downlight_on_black
            display     "inline_block
            padding     "0 8px
        form
          display        "none
          padding        "10px 0 20px 0
          border_top "1px solid $light_blue
          color          "$downlight_on_black
          h2
            color "#FF721A
          span
            display "block
            margin       "0
            padding      "0 10px
          div.field
            padding "0 0 15px 0
            span.value
              display     "block
              color       "$orange
              font_style  "normal
              font_size   "90%"
          div.buttons
            padding "20px 0 0 0

      #sidebar
        float "left
        width "$sidebar_width
        margin_right "10px
        div.intro
          background "transparent"
        div.box
          margin_top "10px
          h3
            margin "0
          div.content
            border_radius "0 0 4px 0
            margin "0




      #content
        padding "0
        overflow "auto

      #Write
        div.box
          div.content
            text_align "center
            padding "$box_margin 0
            textarea
              width "($write_col_width _ ($box_margin * 3))
              min_height "180px"

      #IMs
        width          "380px
        background     "white
        float          "left
        border_radius  "5px
        margin         "10px 0 0 0
        div.box
          border_bottom "1px dashed $dark_blue
          margin   "0
          padding  "3px 7px
          border_radius  "5px 5px 0 0
          div.content
            border_radius  "0
            background     "transparent
            padding        "5px
            margin         "0
          &:last_child
            border "0
        div.highlight_up
          background "#FFF06A"
          _moz_transition     "background_color 0.9s linear"
          _webkit_transition  "background_color 0.9s linear"
          _o_transition       "background_color 0.9s linear"
          _ms_transition      "background_color 0.9s linear"
          transition          "background_color 0.9s linear"
        div.highlight_down
          background "transparent"

      #Why
        float "left
        width "300px
        background "$glass_black_darker
        color "#E1E4E7
        padding "20px 0 10px 0
        border_radius "0 0 4px 4px
        h3
          text_align  "center
          margin_bottom      "0
          padding_bottom     "0
          color "$orange
          font_weight "bold
          font_style "normal
          text_transform "none
        div.content
          margin "0 15px
          padding_bottom "20px
          color "$light_blue

      #Follows
        float "left
        color "#353535
        min_width "300px
        h3.follows
          margin "0 0 10px 0
          background "$glass_black
          font_family "$sans_serif
          text_align "center
          padding "4px
          text_transform "none
          font_size "100%
          color "$orange
        div.box
          background "rgba(255,255,255,0.95)
          border_radius "0 0 3px 3px
          padding_bottom "0
          margin_bottom "10px
          h3
            background "transparent
            color "$dark_blue
            font_size "120%
            text_align "center
            padding "6px 0 0 0
          div.content
            background "transparent
            color "#353535
            padding_bottom "0
            div.msg
              padding "5px 0
              border_bottom "1px dashed $samar_red
              div.title
                color "$dark_blue
              div.body
                font_family "$serif
                font_size "120%
            div.nav
              text_align "center
              a:link, a:visited
                display "block


      div.box

        padding "0 0 10px 0

        h3
          text_align "right
          background "$glass_black
          color "$light_blue
          padding "2px 10px 4px 20px
          font_size "90%
          font_family "$sans_serif
          font_weight "normal
          font_style "italic
          margin "0
        div.content
          background "$glass_black
          padding "10px
          border "0
          border_radius "0 0 3px 0
          text_align "left
          color "#fff
          div.field
            padding_bottom "10px
          label
            color "$orange
            text_transform "none
            font_size "100%
            padding "0 0 3px 0
            display "block
            span.sub
              font_weight "normal
              color "$light_blue
              font_size "90%
          span.value
            color "$light_blue
            font_weight "normal
            text_transform "none
            line_height "1.1em
            padding "0 0 4px 0
          input[type="text"], input[type="password"]
            width "99%
            font_size "150%
          form
            div.errors
              border "1px dashed rgb(128,47, 0)
              border_width "1px 0
              background "transparent
              color "$samar_red

      #Session_Nav
        background "$glass_white
        text_align "center
        float "none

      div.box#New_Session,
      div.box#New_Customer
        text_align "center
        background "$glass_black
        border_radius "0 0 3px 0
        padding "0 0 10px 0
        h3
          background "transparent
        div.content
          width "($sidebar_width _ ($box_margin * 3))
          padding "0
          margin "0
          background "transparent
          margin "0 auto 0 auto



        div.fieldset
          text_align "right"



        button
          margin_top "5px"
    } # === style
