
require 'sinatra'
require 'rack/protection'
require 'content-security-policy'
require './Server/Fake_Mustache/index'
require './Server/Escape_All/index'
require 'Jam_Func'

ss = ENV['SESSION_SECRET']
if !ss
  raise "No session secret set."
end

# -- DB
require 'sequel'
DB = Sequel.connect(ENV['DATABASE_URL'])


ContentSecurityPolicy.configure do |csp|
  csp['default-src'] =  "'self'";
  csp['img-src']     =  "*"
end

# -- configure
use Rack::Session::Cookie, {
  :key          => 'session.rack.rack',
  :path         => "/",
  :expire_after => 60 * 60 * 24 * 7,  # 1 weeks
  :secret       => ss,
  :httponly     => true,
  :secure       => true
}

# -- Middleware
use Rack::Protection
use ContentSecurityPolicy

# -- Helpers
helpers Escape_All::Sinatra

# -- Routes
get "/" do
  Fake_Mustache.new("Public/App/top_slash/markup.mustache.html", {:YEAR=>Time.now.year}).render()
end

get "/unauthenticated" do
  "Not logged in"
end

# ---------------------------- The Models --------------------------
models = %w{
  Customer
}.map { |w|
  require "./Server/#{w}/model"
  require "./Server/#{w}/route"
  m = Object.const_get(w)
}

Jam = Jam_Func.new(*(models.map { |m| m::Jam }))











