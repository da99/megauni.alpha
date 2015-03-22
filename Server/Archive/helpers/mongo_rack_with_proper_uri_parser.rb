
class Rack::Session::Mongo
  def initialize(app, options={})
    super

    pieces            = @default_options[:server].split('/')
    cltn_name         = pieces.pop
    db_name           = pieces.last
    host_port_db_name = pieces.join('/')
    @mutex = Mutex.new
    @connection = ::Mongo::Connection.from_uri( 
       host_port_db_name,
       :pool_size => @default_options[:pool_size],
       :timeout => @default_options[:pool_timeout] 
    )
    @db = @connection.db( db_name )
    @sessions = @db[cltn_name]

    @logger = ::Logger.new( $stdout )
    @logger.level = set_log_level( @default_options[:log_level] )
  end
end # === class
