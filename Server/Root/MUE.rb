

class WWW_App # === CUSTOMIZATIONS ===============

  module CSS
    BORDER_RADIUS = %w{
      _moz_border_radius 
      _webkit_border_radius
      border_radius
      _khtml_border_radius
    }.map(&:to_sym)
    PROPERTIES.concat BORDER_RADIUS
  end

  def var *args
    @vars ||= begin
                v = {}
                v.default_proc = lambda { |h,k|
                  fail ArgumentError, "Key not found: #{k.inspect}"
                }
                v
              end
    return @vars[args.first] if args.size == 1
    name, val  = args
    var!(name, val) unless @vars.has_key?(name)
    val
  end # === def var

  def var! name, val
    @vars[name] = val 
    eval <<-EOF, nil, __FILE__, __LINE__ + 1
          def #{name}
            @vars[:#{name}]
          end
          EOF
    var name
  end

end # === class WWW_App =========================

mu!(:MUE) {
  WWW_App.new {
    link.href('/css/vanilla.reset.css')./
    link.href('/css/fonts.css')./
    link.href('/css/otfpoc.css')./


    var :bg_color            , "#f5f5f5"
    var :heading_color       , '#000'
    var :light_text_color    , '#8E8E8E'
    var :visited_color       , '#956893'
    var :hover_color         , '#C0002C'
    var :dashed_border_color , '#C7C7C7'
    var :subtle_white        , "#fffffc"
    var :white               , '#fff'
    var :black               , '#000'

    def border_radius arg
      ::WWW_App::CSS::BORDER_RADIUS.each { |name|
        alter_css_property name.to_sym, arg
      }
      self
    end

    style {
      background_color bg_color

      a._link {
        color heading_color
      }

      a._visited {
        color visited_color
      }

      a._hover {
        color hover_color
      }

      div.^(:block) {
        border_right "1px dashed #{dashed_border_color}"
        padding      '0 1.5em 1.5em 1.5em'

        div.^(:item) {
          background_color '#fff'
          padding '0 1em 1em 1em'
          margin  '1em'
          border  "1px dashed #D5D5D5"
          color   '#3d3d3d'
          border_radius '5px'
          max_width  '600px'
        }
      } # === div.block

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

      div.id(:nav_bar) {
        padding          '0 0 0.5em 0'
        float            'right'
        margin_right     '1em'
        background_color subtle_white
        position         'absolute'
        top              '0'
        right            '10px'
        border_radius    '0 0 4px 4px'

        a._link {
          display 'block'
          padding  '0.3em 1em'
        }

        a._hover {
          background_color hover_color
          color '#fff'
        }
      }

    } # === style
  }
} # === mu :MUE


