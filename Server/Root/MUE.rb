mu!(:MUE) {
  WWW_App.new {
    link.href('/css/vanilla.reset.css')./
    link.href('/css/fonts.css')./
    link.href('/css/otfpoc.css')./

    heading_color = '#357BB5'
    light_text_color = '#8E8E8E'

    style {
      background_color "#f5f5f5"

      a._hover {
        color '#C0002C'
      }

      div.^(:block) {
        border_right '1px dashed #C7C7C7'
        float        'left'
        padding      '0 1.5em 1.5em 1.5em'
      }

      h1 {
        font_family 'AghjaMedium'
        font_weight 'normal'
        font_style  'normal'
        color       heading_color
        margin      '0.5em 0'
      }

      h3 {
        color          heading_color
        text_transform 'uppercase'
        font_size      'smaller'
        padding        '0.5em 0'
        margin         '0'
      }

      label {
        display 'block'
        span.^(:sub) {
          color light_text_color
        }
      }

      p {
        margin '0 0 0.5em 0'
      }

      div.^(:disclaimer) {
        color light_text_color
      }

    } # === style
  }
} # === mu :MUE


