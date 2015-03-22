
class My_Egg_Timer_Redirect

  def initialize app
    @app = app
  end

  def redirect new_url, stat = 301
    response = Rack::Response.new
    response.redirect( new_url, stat ) # permanent
    response.finish
  end

  def call e
    return redirect('/myeggtimer', 301) if e['PATH_INFO'][/\/myeggtimer%../]
    @app.call e
  end

end # === class My_Egg_Timer_Redirect




