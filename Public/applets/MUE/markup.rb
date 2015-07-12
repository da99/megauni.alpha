
require "erector"

module Megauni
  module WWW_App

    BORDER_RADIUS = %w{
    }.map(&:to_sym)

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
end # === Megauni


module Megauni

  class MUE < Erector::Widget

    def nav_bar
      div.nav_bar! {
        a.href('/') { 'megauni home' }
        a.href('/log-out') { 'Log-Out' }
      }
    end

    def content
      html {

        head {
          link.href('/css/vanilla.reset.css')./
          link.href('/css/fonts.css')./
          link.href('/css/otfpoc.css')./
          title(@title || 'no title' )
        } # === head

        body {

        }

        script('/scripts/turu/turu.js')
      } # === html
    end # === def content

  end # === class MUE

end # === module Megauni






