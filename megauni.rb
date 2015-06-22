
require 'cuba'
require 'www_app'

FILE_403   = File.read("Public/403.html")
FILE_404   = File.read("Public/404.html")
FILE_500   = File.read("Public/500.html")


class Megauni

  FILE_VALS = {}
  VALS      = {}
  VALS.default_proc = lambda {|h,k|
    fail ArgumentError, "Key not found: #{k.inspect}"
  }

  module Server

    module Constant
      def new_constant name, arg = :undefined
        fail "Already defined: #{name.inspect}" if VALS.has_key?(name)

        VALS[name] = if block_given?
                       yield
                     else
                       arg.first
                     end
      end # === def new_constant

      def constant name
        fail "Key not found: #{name.inspect}" unless VALS.has_key?(name)
        VALS[name]
      end

    end # === module Constant

    module Plugin

      include Constant

      def new_constant name, arg = :undefined
        fail "Already defined: #{name.inspect}" if VALS.has_key?(name)

        VALS[name] = if block_given?
                       yield
                     else
                       arg.first
                     end
      end # === def new_constant

      def constant name
        fail "Key not found: #{name.inspect}" unless VALS.has_key?(name)
        VALS[name]
      end

      def new_var name, v = :undefined
        file = caller(1,1).first.split(':').first
        FILE_VALS[file] ||= {}

        FILE_VALS[file][name] = if block_given?
                                  yield
                                else
                                  v
                                end
      end # === def new_var

      def var name
        file = caller(1,1).first.split(':').first

        if !FILE_VALS[file] || !FILE_VALS[file].has_key?(name)
          fail "Key not found: #{name.inspect}"
        end

        FILE_VALS[file][name]
      end # === def var

    end # === Plugin

    module DSL

      include Plugin

      def set name, val
        file = caller(1,1).first.split(':').first
        FILE_VALS[file] ||= {}
        FILE_VALS[file][name] = val
      end

      def setting name, *args
        file = caller(1,1).first.split(':').first
        FILE_VALS[file] ||= {}

        case
        when FILE_VALS[file].has_key?(name)
          FILE_VALS[file][name]
        when args.empty? && block_given?
          FILE_VALS[file][name] = yield
        when args.size == 1
          FILE_VALS[file][name] = args.first
        when args.size > 0 && block_given?
          fail "Too many arguments: arg and block"
        when args.size > 1
          fail "Unknown args: #{args.inspect}"
        else
          fail "Key not found: #{name.inspect}"
        end
      end

      def use app, *args
        if block_given?
          return Cuba.use(app, *args, &(Proc.new))
        else
          return Cuba.use(app, *args)
        end
      end # === def use


      def new_middleware app
        # if it's not middleware, we turn it into middleware
        #   and use it.
        Cuba.use(Class.new {
          const_set :APP, app

          def initialize app, *args
            @app = app
          end

          def call env
            dup._call env
          end

          def _call env
            status, headers, body = (result = self::class::APP.call env)

            is_empty = status == 404 && (!body || body.empty?)
            if is_empty
              @app.call env
            else
              result
            end
          end
        })
      end # === def new_middleware

    end # === module DSL

  end # === module Server
end # === Megauni

extend      Megauni::Server::DSL
Cuba.plugin Megauni::Server::Plugin

use Rack::CommonLogger

require 'da99_rack_protect'
use Da99_Rack_Protect do |da99|
  if ENV['IS_DEV']
    da99.config(:host, :localhost)
  else
    da99.config(:host, 'megauni.com')
  end
end

# 500 errors ===================
# We place this at the top level
# to catch any server app errors
# (aka 500).
  Cuba.use(Class.new {
    def initialize app
      @app = app
    end

    def call env
      dup._call env
    end

    def _call env
      @app.call env
    rescue Object => ex
      if ENV['IS_DEV']
        puts ex.message
        ex.backtrace.map { |b| puts b }
      end
      [500, {'Content-Type'=>'text/html'}, [FILE_500]]
    end
  })

%w{
  Timer_Public_Files
  My_Egg_Timer_Redirect
  Surfer_Hearts_Archive
  Mu_Archive_Redirect
  Mu_Archive
}.each { |name|

 require "./Server/Archive/#{name}"
 use Object.const_get(name)

}

if ENV['IS_DEV']
  require "./Server/Archive/Public_Files"
  use Public_Files, [ 'Public', Surfer_Hearts_Archive::Dir ]
end

require './Server/Root/MUE'
require './Server/Root/root'
require './Server/Root/home' if ENV['IS_DEV']
require './Server/Root/@screen_name'
require './Server/Root/post'

Cuba.define do

  # 404 errors ===================
  on default do
    res.status = 404
    res.write FILE_404
  end # on get

end # === Cuba.define







