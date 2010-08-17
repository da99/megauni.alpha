require 'launchy'
require 'rest_client'

MAX_DB_SIZE_IN_MB = 12.0

def check_this_url url, r_text
  begin
    results = RestClient.get( url )
    if results !~ r_text
      puts_red "Could not find #{r_text.inspect} @ #{url}"
    end
  rescue RestClient::ResourceNotFound, RestClient::RequestFailed, RestClient::RequestTimeout
    puts_red "Homepage problem: #{url} - #{$!.message}"
  end
end

def git_commit_pending?
  output = `git status 2>&1`
  case $?.exitstatus
  when 0
    true
  when 1
    false
  else
    raise "Unknown error: exitstatus: #{$?.exitstatus}  -  #{output}"
  end
end

namespace 'git' do
  
  desc 'Executes: git add . && git add -u && git status'
  task :update do 
    sh 'git add . && git add -u'
    sh 'git reset HEAD "templates/en-us/mustache/*.*"'
    sh 'git status'
  end
  
  
  desc 'Gathers comment and commits it. Example: git:commit msg="My commit." '
  task :commit => [:update] do
    
    raw_msg = ENV['msg']

    comment = assert_not_empty( raw_msg )
      
    if git_commit_pending?
      sh( 'git commit -m %s ' % comment.inspect )
      puts_white "COMMITTED: #{comment}"
    else
      puts_red "NO GO: Nothing to commit."
    end

  end

  
  desc "Used to update and commit development checkpoint. Includes the commit comment for you."
  task :dev_check do
    ENV['msg'] ||= 'Development checkpoint.'
    Rake::Task['git:commit'].invoke
  end # === task

  
  desc "Prep push code to Heroku."
  task :prep_push do 

    Rake::Task['views:compile'].invoke
    ENV['msg'] = 'Development checkpoint. (Mustache/css compilation.)'
    Rake::Task['git:dev_check'].invoke
    

    # # Check if specs all pass.
    # total, passed, errors = run_task( 'fefe:tests' )
    # if total == passed
    #   raise "#{failed} tests failed."
    # else
    #   puts_white 'All specifications passed.'
    # end

  end # === task

  desc 'Updates production DB indexes, pushes code.
  SKIP_PREP = false
  GEM_UPDATE = false
  SKIP_MONGO_CHECK = false'
  task :push do
    
    # Update DB indexes on production server.
    puts_white "Updating indexes on production DB server..."
    orig_env = ENV['RACK_ENV']
    ENV['RACK_ENV'] = 'production'
    require 'megauni'
    Couch_Plastic.ensure_indexes()

    unless ENV['SKIP_MONGO_CHECK'] 
      Rake::Task['db:check_size'].invoke
    end

    unless ENV['SKIP_PREP']
      Rake::Task['git:prep_push'].invoke
    end
    
    ENV['RACK_ENV'] = orig_env
    
    if ENV['GEM_UPDATE']
      puts_white "Updating gems on Heroku..."
      results = `heroku console "IO.popen('gem update 2>&1') { |io| io.gets }" 2>&1`
    else
      results = ''
    end

    if results['ERROR']
      puts_red results
      exit
    else
      puts_white results
      puts_white "Pushing code to Heroku..."
      sh('git push heroku master')
      Launchy.open('http://www.megauni.com/')
    end

  end

  desc 'Pushed the code and nothing else.'
  task :just_push do
    ENV['SKIP_PREP']        = true.to_s
    ENV['SKIP_MONGO_CHECK'] = true.to_s
    ENV['SKIP_GEM_UPDATE']  = true.to_s
    Rake::Task['git:push'].invoke
  end

  
end # === namespace git
