# ====================================================================================
# ====================================================================================

class Model < Thor

  include Thor::Sandbox::CoreFuncs
  
  desc  :list, 'Display a list of all models.'
  def list
    Pow("models").each { |ele|
      file_basename = File.basename(ele.to_s)
      if ele.file? && file_basename !~ /init.rb\z/ && file_basename[/\.rb\z/]
        whisper( file_basename.sub('.rb', '').camelize  )
      end
    }
  end

  desc  :create, "Create a new model in the /model directory. Case and plurality are handled automatically."
  def create
    m         = ask('Name of new model:').strip.camelize.singularize

    file_path = Pow("models/#{m.underscore}.rb")
    
    txt = eval( %~"#{Pow(File.expand_path('~/' + PRIMARY_APP + '/models/template.txt')).read}"~ )
    write_file_or_raise(file_path, txt)
    
    whisper "Finished writing: #{file_path}"
    
  end

  desc  :destroy, "Move a model to a scrap area relative to working directory. (Moves controller and views too.)" 
  def destroy
    m = ask('Name of model:').strip.camelize
    scrap_dir = Pow!( ask('Name of scrap directory (default ../nptv_scraps)') { |q| q.default =  '../nptv_scraps' } )
    model_file = Pow!("models/#{m.underscore}.rb")
    action_file = Pow!("actions/#{m.underscore}.rb")
    skins_dir = Pow!("views/skins")
    
    raise "Scraps dir does not exist: #{scrap_dir}" if !scrap_dir.directory?
    raise "Skins dir does not exist: #{skinds_dir}" if !skins_dir.directory?
    ['models', 'views', 'actions'].each do |check_dir|
      raise "#{check_dir.capitalize} dir does not exist in Scrap Dir." if !(scrap_dir / check_dir ).directory?
    end

    exec_and_check = lambda { |comm|
      results = capture_all(comm)
      raise "Something went wrong when executing: #{comm}" if !results
      results
    }

    if model_file.exists?
      shout "Moving model file: #{model_file}"
      new_model_file = (scrap_dir / "models" / File.basename(model_file) )
      exec_and_check.call "mv #{model_file} #{new_model_file}"

    else
      shout "Model file not found. Skipping..."
    end

    if action_file.exists?
      shout "Moving action file: #{action_file}"
      new_action_file = (scrap_dir / "actions" / File.basename(action_file) )
      exec_and_check.call "mv #{action_file} #{new_action_file}"
    else
      shout "Action file not found. Skipping..."
    end
    
    skins_dir.each { |dir|
      if dir.directory?
        shout "In directory: #{dir}"
        [ 'new', 'show', 'edit' ].each { |view_name|
          view_file = ( dir / "#{File.basename(model_file).sub('.rb', '')}_#{view_name}.rb")
          if view_file.file?
            scrap_view_dir = ( scrap_dir / 'views' / File.basename(dir) )
            raise "View dir not found in scrap dir: #{scrap_view_dir}" if !scrap_view_dir.directory?
            
            new_view_file = ( scrap_view_dir / File.basename(view_file) )
            raise "New view file already exists. Delete it to continue: #{new_view_file}" if new_view_file.exists?
            
            shout "Moving view file: #{view_file}"
            exec_and_check.call "mv #{view_file} #{new_view_file}"
          end
        }
      end
    }
    
    migration_dir = Pow!( "migrations" )
    scrap_migration_dir = ( scrap_dir / "migrations" )
    migration_dir.each { |entry|
      if entry.file? && entry.to_s["create_#{m.underscore.pluralize}.rb"]
        new_file = (scrap_migration_dir / File.basename(entry) )
        shout "Moving migration file: #{entry}"
        exec_and_check.call "mv #{entry} #{new_file}"
      end
    }
  end # ==== task :destroy
  
end # === namespace :model


