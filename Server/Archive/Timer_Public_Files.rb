
class Timer_Public_Files

  def initialize orig
    @app = orig
  end

  def call e
    orig = @app
    if !e['PATH_INFO']['favicon.ico'] && e['PATH_INFO'][/^\/(my-egg-timer|busy-noise)\/.+/]
      Rack::Builder.new do
        use Rack::Static,
          :urls=>["/busy-noise", '/my-egg-timer'],
          :root=>'Public'
        run orig
      end.call e
    else
      @app.call e
    end
  end

end # === class Timer_Public_Files
