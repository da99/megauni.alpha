module Sequel
  class << self
    def add_utc_to_pg_time(s)
      if !s[/[\+\-][0-9]{1,2}\z/]
        s + ' UTC' 
      else
        s
      end
    end
    
    [:time, :datetime, :date].each { |meth|
      orig_meth = "string_to_#{meth}".to_sym
      orig_meth_new = "#{orig_meth}_wo_utc".to_sym
      new_meth = "#{orig_meth}_w_utc".to_sym
      define_method( new_meth ) { |s|
        send orig_meth_new, add_utc_to_pg_time(s)
      }
      alias_method orig_meth_new, orig_meth
      alias_method orig_meth, new_meth
    }
  end
end

module Sequel::Postgres::DatasetMethods
    def literal_time_w_utc(v)
      new_v = v.utc? ? v : v.utc
      literal_time_wo_utc(v)
    end
    alias_method :literal_time_wo_utc, :literal_time
    alias_method :literal_time, :literal_time_w_utc
    
    def literal_datetime_w_utc(v)
      literal_time( Time.parse( v.to_s ) )
    end
    alias_method :literal_datetime_wo_utc, :literal_datetime
    alias_method :literal_datetime, :literal_datetime_w_utc
end
