class Issue < Sequel::Model

  def self.required_cols
    @required_cols ||= [ :app_name, :title,
                    :body, 
                    :environment, 
                    :path_info,
                    :user_agent, 
                    :ip_address ]
  end 
  
  def self.data_template
    required_cols.inject({}) { |m, k|
      m[k] = ''
      m
    }
  end
  def self.create(cols)
  
    valid_cols = required_cols

    invalid_cols = cols.keys - valid_cols
    raise "Hacker attempt: Invalid columns: #{invalid_cols.inspect}" if !invalid_cols.empty? 
    
    missing_cols = valid_cols - cols.keys
    raise "Missing cols: #{missing_cols.inspect}" if !missing_cols.empty?
      
    coder = HTMLEntities.new
    rec = new
    cols.each { |k,v| 
      rec[k] = coder.encode( v, :named )
      if k == :ip_address && v.is_a?(String)
        rec[k] = v.sub(/\A\:\:ffff\:/, '')
      end     
      
      if k != :body && v.is_a?(String) && v.size > 200
        rec[k] = rec[k][0,250]
      end
    }
    rec.safe_save
  end

  def safe_save(*args)
    begin
      save(*args)
    rescue
      MiniIssue.create($!.message, $!.backtrace.join("\n"))
    end
  end
      
  def before_save 
    self[:created_at]= Time.now.utc
    super
  end
  
  def before_update
    self[:modified_at] = Time.now.utc
    super
  end
  
  def resolve
    self[:resolved] = true
    safe_save(:changed=>true)
  end
  
  def unresolve
    self[:resolved] = false
    safe_save(:changed=>true)
  end
  
  def self.miniuni_error(env, app_env)
    data = data_template.merge({  :app_name=>'mini uni',
                                  :title=>env['sinatra.error'].message, 
                                  :path_info=>env['PATH_INFO'],
                                  :body=>env['sinatra.error'].backtrace.join("\n"),
                                  :environment=> app_env.to_s,
                                  :user_agent=> env['HTTP_USER_AGENT'].to_s,
                                  :ip_address=> env['REMOTE_ADDR']
    })
    create(data)
  end
end # === class
