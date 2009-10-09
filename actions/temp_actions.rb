get '/economy/' do
  describe :topic, :economy
  render_mab
end

get '/music/' do
  describe :topic, :music
  render_mab
end

get '/sports/' do
  describe :topic, :sports
  render_mab
end

get '/housing/' do
  describe :topic, :housing
  render_mab
end

get '/news/' do
  describe :topic, :news
  render_mab
end

get '/bubblegum/' do # :index
  @news = News.reverse_order(:created_at).limit(10).all
  @news_tags = NewsTag.all
  describe :topic, :bubblegum
  render_mab
end


get '/computer/' do
  describe :topic, :computer
  render_mab
end

get '/preggers/' do
  describe :topic, :preggers
  render_mab
end 

get '/hair/' do
  describe :topic, :hair
  render_mab
end

get '/back-pain/' do
  describe :topic, :back_pain
  render_mab
end

get '/child-care/' do
  describe :topic, :child_care
  render_mab
end

get '/arthritis/' do
  describe :topic, :arthritis
  render_mab
end

get '/flu/' do
  describe :topic, :flu
  render_mab
end

get '/heart/' do
  describe :topic, :heart
  render_mab
end

get '/cancer/' do
  describe :topic, :cancer
  render_mab
end

get '/hiv/' do
  describe :topic, :hiv
  render_mab
end

get '/depression/' do
  describe :topic, :depression
  render_mab
end

get '/dementia/' do
  describe :topic, :dementia
  render_mab
end

get '/meno-osteo/' do
  describe :topic, :meno_osteo
  render_mab
end

get '/health/' do
  describe :topic, :health
  render_mab
end
