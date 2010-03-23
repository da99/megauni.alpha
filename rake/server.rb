# ====================================================================================
# ====================================================================================

namespace :server do
  
	desc 'Start the server.'
	task :http do
		exec 'thin -p 4567 -R config.ru start'
	end

  task :nginx do
    it 'Starts up Nginx, after invoking nginx_stop.'
    steps {
      require 'rush'
      if Rush.processes.filter(:cmdline=>/nginx/).size > 0
        puts_red 'Shutdown nginx first.'
        exit(1)
      end
      exec 'sudo /etc/init.d/nginx start'
    }
  end

  task :nginx_stop do
    it 'Stops Nginx.'
    steps {
      exec 'sudo /etc/init.d/nginx stop'
    }
  end

  # These use 'exec', which replaces the current process (i.e. Rake)
  # More info: http://blog.jayfields.com/2006/06/ruby-kernel-system-exec-and-x.html
  task :light do
    it "Runs the lighttpd server. (Uses :exec to replace current process.)"
    steps {
      require 'rush'
      if Rush.processes.filter(:cmdline=>/lighttpd/).size > 0
        puts_red 'Shutdown lighttpd first.'
        exit(1)
      end
      exec "sudo /etc/init.d/lighttpd start"
    }
  end

  task :dev do
    it "Runs Unicorn in :development mode. (Uses :exec.)"
    steps {
      fefe_run 'sass:delete'
      exec "unicorn -p 4999"
    }
  end

	desc "Kill Unicorn worker, which will then be re-started."
  task :reload do
		puts_white 'Restarting...'
		require 'rush'
		output = Rush.processes.filter(:cmdline=>/unicorn worker/).kill
		puts_white 'Done.'
		output
  end
  
  desc 'Start CouchDB server.'
  task :db do 
    exec("sudo -i -u couchdb couchdb -b")
  end
  
  desc 'Shutdown background CouchDB server process.'
  task :shutdown_db do
    exec("sudo -i -u couchdb couchdb -d")
  end
  
  desc 'Open CouchDB Futon in the Browser'
  task :futon do
    Launchy.open 'http://127.0.0.1:5984/_utils/index.html'
  end


end # === namespace :server

