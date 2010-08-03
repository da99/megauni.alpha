require 'json'
require 'mongo'

require 'mongo'
# COLLS = %w{Clubs Members Member_Usernames Messages}

def compile_with_mongo_ids hsh
  case hsh
  when Array
    hsh.map { |v| compile_with_mongo_ids(v) }
  when Hash
    if hsh['$oid']
      BSON::ObjectID.from_string(hsh['$oid'])
    else
      new_hsh = {}
      hsh.each { |k, v| 
        new_hsh[k] = compile_with_mongo_ids(v)
      }
      new_hsh
    end
  else
    hsh
  end
end

# PRODUCTION_DB = File.read(File.expand_path '~/cloud.txt').strip
# DB_PRODUCTION = [ File.dirname(PRODUCTION_DB), File.basename(PRODUCTION_DB) ]
namespace :db do
  
  desc 'Check if MongoDB is approaching size limit.'
  task :check_size do
    orig_env = ENV['RACK_ENV']
    ENV['RACK_ENV'] = 'production'
    require 'megauni'
    
    puts_white "Checking size of MongoDB account..."
    db_size = `mongo #{DB_HOST} -u #{DB_USER} -p #{DB_PASSWORD}  --eval "db.stats().storageSize / 1024 / 1024;" 2>&1`.strip.split.last.to_f
    if db_size > MAX_DB_SIZE_IN_MB 
      puts_red "DB Size too big: #{db_size} MB"
      exit
    else
      puts_white "DB Size is ok: #{db_size} MB"
    end
    
    ENV['RACK_ENV'] = orig_env
  end
  
  desc "Delete, then re-create database. Uses ENV['RACK_ENV']. Defaults to 'development'." 
  task :reset! do
    
    ENV['RACK_ENV'] ||= 'development'
    # raise "Not allowed in environment: #{ENV['RACK_ENV']}" unless ['development', 'test'].include?(ENV['RACK_ENV'])

    require File.basename(File.expand_path('.'))

    Couch_Plastic.reset_db!
    puts_white "Removed all records and added new indexes (if any)."

    # conn = Mongo::Connection.new
    # conn.drop_database(DB.name)
    # 
    # puts_white "Deleted: #{DB.name}"

    # Couch_Plastic.ensure_indexes
    # puts_white "Created indexes."

    # Grab some sample data
    Rake::Task['db:sample_data'].invoke
    
    if ENV['RACK_ENV'] === 'test'
      Rake::Task['db:test_sample_data'].invoke
    end
  end # ===

  desc 'Grab some sample data from production database'
  task :sample_data do
    require File.basename(File.expand_path('.'))
    
    data = JSON.parse(File.read(File.expand_path('rake/sample_data_for_dev.json')))
    
    data.each do |raw_doc|
      doc = compile_with_mongo_ids(raw_doc)
      raise ArgumentError, "No :data_model specified: #{doc.inspect}" if doc['data_model'].to_s.empty?
      DB.collection(doc['data_model']).insert(doc)
    end
    
    puts_white "Inserted sample data."
  end

  desc 'Get all data from production database and store it as a JSON file on Desktop.'
  task :save_all_docs do
    # Grab some sample data
    require 'json'
    require 'rest_client'
    base_url = 'http://miniuni:gkz260cyxk@miniuni.cloudant.com:5984/megauni_stage'
    url      = File.join( base_url, "/_all_docs")
    mess     = JSON.parse(RestClient.get(url + '?include_docs=true').body)['rows']
    
    
    processed = mess.map { |d|
      d['doc'].delete 'rev'
      d['doc'].delete '_rev'
      if d['doc']['_id'] =~ /_design/
        nil
      else
        d['doc']
      end
    }.compact

    File.open(File.expand_path('~/Desktop/all_data.json'), 'w') do |file|
      file.puts JSON.pretty_generate(processed)
    end
    
    puts_white "Finished writing data."
    
  end

  desc 'Update design document only. Uses ENV[\'RACK_ENV\']. Development by default.'
  task :reset_design_doc do
    ENV['RACK_ENV'] ||= 'development'
    require File.basename(File.expand_path('.'))
    Couch_Plastic.ensure_indexes
    puts_white "Updated indexes."
  end
  
  desc "Add in sample data for tests."
  task :test_sample_data do

    # === Create Regular Member 1 ==========================
    # === Create Regular Member 2 ==========================
    # === Create Regular Member 3 ==========================
    # === Create Admin Member ==========================
    "regular-member-1" # password: regular-password
    "regular-member-2" # password: regular-password
    "regular-member-3" # password: regular-password
    "admin-member-1" # password: admin-password

    (1..3).to_a.each do |i|
      Member.create( 
        nil, 
        :add_username => "regular-member-#{i}", 
        :password => 'regular-password',
        :confirm_password => 'regular-password'
      )
    end

    doc = Member.create(
      nil, 
      :add_username => "admin-member-1",
      :password => 'admin-password',
      :confirm_password => 'admin-password'
    )

    doc_data = doc.data.as_hash
    doc_data['security_level'] = 'ADMIN'
    

    Member.db_collection.update(
      {'_id' =>doc_data['_id']}, 
      doc_data,
      :safe=>true
    )

    puts_white 'Inserted sample data just for tests.'
  end # ======== :db_reset!

  desc "Export the production MongoDB to development machine."
  task :export_production do
    raise "Not done: Figure out how to get list of collections."
      file_loc = File.expand_path('~/Desktop/')
      COLLS.each { |coll|
        loc = File.join(file_loc, "db_backup.#{coll}.json")
        cmd = "mongoexport -v -o #{loc} -h #{DB_HOST}:#{DB_PORT.to_s} -d #{DB_NAME} -c #{coll} -u #{DB_USER} -p #{DB_PASSWORD}"
        puts cmd
        puts `#{cmd} 2>&1`
        puts "\n"
      }
  end

  desc "Import backup files to production machine."
  task :import_production do
      file_loc = File.expand_path('~/Desktop/')
      COLLS.each { |coll|
        loc = File.join(file_loc, "db_backup.#{coll}.json")
        cmd = "mongoimport -v --drop --file #{loc} -h pearl.mongohq.com:27027/mu02 -d mu02 -c #{coll} -u #{DB_USER} -p #{DB_PASSWORD}"
        puts cmd
        puts `#{cmd} 2>&1`
        puts "\n"
      }

  end
end # === namespace :db

