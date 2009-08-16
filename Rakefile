require 'rubygems'
require "highline/import"

def print_this(*args)
  args.each {|new_line|
    if new_line.empty?
      print "\n"
    else
      print "===>  #{new_line}\n\n" 
    end
  }
end

def exec_this(command)
  `#{command} 2>&1`
end

def raise_this( error_str )
  print_this '', error_str, ''
  raise
end




namespace :git do

  desc "Execute: git add . && git add -u && git status"
  task :update do
    results = `git add . && git add -u && git status`
    print_this results
  end

  desc "Gathers comment and commits it using: git commit -m '[your input]' "
  task :commit do
    Rake::Task['git:update'].invoke
    new_comment = ask('Enter comment (type "E" to end it):') { |q|
      q.gather = 'E'
    }
    results = `git commit -m '#{new_comment.join("\n").gsub("'", "\\\\'")}'`
    print_this ''
    print_this results
  end
  
  task :status do
    print_this `git status`
  end
  
  desc "Used to update and commit development checkpoint. Includes the commit comment for you."
  task :dev_check do
    Rake::Task['git:update'].invoke
    commit_results = `git commit -m "Development checkpoint."`
    print_this ''
    print_this commit_results
  end
  
  task :push do
    status_results = `rake git:status 2>&1`
    if status_results['nothing to commit']
      print_this 'Please wait as code is being pushed to Heroku...'
      push_results = `git push heroku master 2>&1`
      print_this push_results
    else
      raise_this "Uncommited code: \n\n #{status_results}"
    end
  end

end # ==== namespace :git


namespace :run do
  # These use 'exec', which replaces the current process (i.e. Rake)
  # More info: http://blog.jayfields.com/2006/06/ruby-kernel-system-exec-and-x.html
  task :light do
    exec "sudo /etc/init.d/lighttpd start"
  end

  task :dev do
    exec  "thin start --rackup config.ru -p 4567"
  end
  
  task :tests do
    exec 'DATABASE_URL=postgres://da01:xd19yzxkrp10@localhost/newsprint-db-test'
  end

end
