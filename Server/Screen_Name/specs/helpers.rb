
class Screen_Name
  class Spec

    CACHE = {
      i: 0
    }

    attr_reader :post, :comment, :o
    def initialize settings, prefix, *args
      fail ArgumentError, "Unknown args: #{args}" unless args.empty?

      @post     = nil
      @settings = settings

      vals = {
        :screen_name => "#{prefix}_#{CACHE[:i] += 1}_#{Time.now.utc.to_i}"
      }

      if settings.has_key?(:default_privacy)
        vals[:privacy] = Screen_Name.const_get settings[:default_privacy]
      end

      @prefix = prefix
      @o = Screen_Name.create vals
    end

    def method_missing *args
      @o.send(*args) {
        yield
      }
    end

    def is type
      @o = @o.class.update(
        id: @o.id,
        privacy: @o.class.const_get(type.to_s.upcase.to_sym)
      )
      self
    end

    def allows sn
      Link.create owner_id: o.id, type_id: Link::ALLOW_ACCESS_SCREEN_NAME, asker_id: sn.id, giver_id: o.id
      self
    end

    def blocks sn
      Link.create owner_id: o.id, type_id: Link::BLOCK_ACCESS_SCREEN_NAME, asker_id: sn.id, giver_id: o.id
      self
    end

    def posts msg, *args
      @post = computer({:msg=>msg.to_s}, *args)
      Link.create owner_id: o.id, type_id: Link::POST_TO_SCREEN_NAME, asker_id: @post.o.id, giver_id: o.id
      if block_given?
        @settings[:post] = @post
        @post.instance_eval(&Proc.new)
        @settings[:post] = nil
      end
      @post
    end

    def comments msg, *args
      @comment = computer({:msg=>msg.to_s}, *args)
      Link.create owner_id: o.id, type_id: Link::COMMENT, asker_id: @comment.o.id, giver_id: @settings[:post].o.id
      @comment
    end

    def computer code, priv = nil
      vals = {
        owner_id: @o.id,
        code:     code
      }
      if priv
        vals[:privacy] = priv
      else
        if @settings.has_key?(:default_privacy)
          vals[:privacy] = Computer.const_get @settings[:default_privacy]
        end
      end
      Computer.create( vals )
    end

    def reads type
      @read_type = type
      self
    end

    def of post
      Link.read(@read_type, o.id, post.respond_to?(:o) ? post.o.id : post)
    end

  end # === SN
end # === class Screen_Name
