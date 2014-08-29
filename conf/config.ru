
require "./Server/Okdoki/app"
require 'escape_utils/html/rack' # to patch Rack::Utils
require 'escape_utils/html/cgi' # to patch CGI

lang=ENV['LANG']
if not lang['UTF-8']
  raise "env $LANG is not set."
end

ss = ENV['SESSION_SECRET']
if !ss
  raise "No session secret set."
end

# -- configure
#    Place the session middleware
#    first, before all other session protection
#    middleware takes effect. See:
#    https://github.com/sinatra/sinatra/issues/757#issuecomment-23281691
use Rack::Session::Cookie, {
  :key          => 'rack.session',
  :path         => "/",
  :expire_after => 60 * 60 * 24 * 7,  # 1 weeks
  :secret       => ss,
  :httponly     => true,
  :secure       => true
}

run Sinatra::Application
