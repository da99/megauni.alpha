

class Failed_Log_In_Attempt

  Too_Many = Class.new( StandardError )
  
  include Go_Mon::Model
  MAX = 4
  
  make :owner_id,   :mongo_object_id
  make :username,   :anything
  make :date,       :anything
  make :time,       :anything
  make :ip_address, :anything
  make :user_agent, :anything

  # ==== Class Methods  ====
  
  class << self

    def log_failed_attempt( ip_address )

      params = { :ip_address=>ip_address, :created_at=>utc_today }
      old_la = Failed_Log_In_Attempt.find.ip_address(ip_address).created_at(utc_today).go!.first
      
      return Failed_Log_In_Attempt.create( params ).total if !old_la
     
      # Why use ".this.update"? Answer: http://www.mail-archive.com/sequel-talk@googlegroups.com/msg02150.html
      old_la.this.update :total => 'total + 1'.lit
      new_total = old_la[:total] + 1  

      if new_total >= MAX
          raise Too_Many,  "#{new_total} log-in attemps for #{old_la.ip_address}"
      end
      
      new_total

    end # === def self.log_failed_attempt

    def too_many?(ip_address)
      attempts = Failed_Log_In_Attempt.find.ip_address(ip_address).date(utc_today).go!
      attempts.size >= MAX
    end
    
    def utc_today
      Time.now.utc.strftime("%Y-%m-%d")
    end
    alias_method :utc_date, :utc_today
    
    def for_today mem
      find.owner_id(mem.data._id).date(utc_date).go!
    end

  end # ===

  # ==== Authorizations ====
   
  class << self
    def create editor, raw_raw_data
      
      %w{ date time }.each { |fld|
        raw_raw_data.delete fld
        raw_raw_data.delete fld.to_sym
      }
      raw_raw_data['date'] = Go_Mon.utc_date_now 
      raw_raw_data['time'] = Go_Mon.utc_time_now
      
      super.instance_eval do
        ask_for :owner_id, :username, :date, :time,
                :ip_address, :user_agent
        save_create
      end
    end
  end
 
  def allow_to? action, editor
    case action
    when :create
      true
    when :read
      false
    when :update
      false
    when :delete
      false
    end
  end

  
  # ==== Accessors ====

end # === end Failed_Log_In_Attempt
