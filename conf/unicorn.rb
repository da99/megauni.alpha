
worker_processes  1

if ENV['USER'] == 'root'
  user "deploy_okdoki", "deploy_okdoki"
end

preload_app true

before_fork do |server, worker|
  DB.disconnect if defined? DB
end

