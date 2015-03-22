
class Custom_Tag_Proxy

  attr_reader :args, :attrs, :_blok, :_draw_blok

  def initialize new_builder, *new_args, &new_draw_blok
    @builder    = new_builder
    @args       = []
    @attrs      = {}
    @_blok      = nil
    @_draw_blok = new_draw_blok
    
    if not new_args.empty?
      @_blok = new_args.pop if new_args.last.is_a?(Proc)
      _draw(*new_args, &@_blok)
    end
    
  end

  def method_missing *args, &blok
    if args.first.to_s['!']
      attrs[:id] = args.shift
    else
      attrs[:class] = args.shift
    end
    
    ( not args.empty? || blok ) ?
      _draw(*args, &blok) :
      self
  end

  def _draw *new_args, &blok
    @args = new_args if not new_args.empty?
    @_blok = blok if blok
    _draw_blok.call(self)
  end

end # === class Custom_Tag_Proxy
