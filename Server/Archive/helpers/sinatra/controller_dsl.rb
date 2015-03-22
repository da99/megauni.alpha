def controller name, &blok
  ControllerDSL.new(name, &blok)
end

configure do

  class ControllerDSL

    private
      attr_writer :name
    public
      attr_reader :name

    def initialize raw_name, &blok
      self.name = raw_name
      instance_eval( &blok )
    end

    [:get, :put, :post, :delete].each { |action|
      eval %~
        def #{action} *args, &blok
          new_action #{action.inspect}, args, blok
        end
      ~
    }

    def new_action action_name, args, blok
      option_name = "__#{action_name}_#{blok.object_id}__".to_sym

      set option_name, lambda { blok } # Uses Sinatra's :set method.

      line = __LINE__
      code = %~
        #{action_name}(*(#{args.inspect})) do
          controller #{name.inspect}
          instance_eval( &(options.#{option_name}) )
          # options.#{option_name}.inspect
        end
      ~
      self.class.instance_eval code, __FILE__, line

    end

  end # === class ControllerDSL

end # === configure
