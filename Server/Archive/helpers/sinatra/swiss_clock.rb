# require 'tzinfo'

##########################################################
# I made this instead of the using ActiveSupport 
# for time-related methods.
##########################################################
helpers do

  def js_epoch_time(epoch_time)
    epoch_time.to_i * 1000
  end
  

  
  def js_date(dt)
    dt.strftime('%B, %d %Y %H:%M:%S UTC')
  end  
   
  # method is modified code from: http://safari.oreilly.com/0768667208/ch07lev1sec23 
  def total_days 
    mdays = [nil,31,28,31,30,31,30,31,31,30,31,30,31] 
    mdays[2] = 29 if Date.leap?(@year) 
    mdays[@month] 
  end 
   
  def start_wday 
    t = Time.gm(@year, @month) 
    t.wday 
  end 
   
  def month=(month) 
    month = month.to_i 
    @month = ( month >0 && month <13 ) ? month : 1  
  end 
   
  def year=(year) 
    year = year.to_i 
    @year = (year >= 2006 && year <= (Time.now.year + 2) ) ?  year  : @year 
  end


  # =========================================================
  # Returns a string for :strftime methods.
  # The format is for American English users.
  # =========================================================
  def time_string_format
    '%a, %b %d, %Y @ %I:%M %p'
  end
  
  # =========================================================
  # Need a reason to use slow :tzinfo instead of something faster?
  # See here: http://www.ruby-forum.com/topic/79431
  # =========================================================
  def utc_to_local( utc, tz_string )
    TZInfo::Timezone.get(tz_string).utc_to_local( utc )
  end
  

  # =========================================================
  # 
  # =========================================================
  def utc_to_local_string( tz_string, utc_time, string_format=nil)
    string_format ||= SwissClock.time_string_format
    utc_to_local(tz_string, utc_time).strftime(string_format)
  end
  
  # =========================================================
  # Returns valid timezone or false. Does not raise exception.
  # =========================================================
  def valid_timezone?( tz_name )
    begin
      validate_timezone(tz_name)
    rescue SwissClock::Invalid
      false
    end
  end
  
  # =========================================================
  # 
  # =========================================================
  def validate_timezone( tz_name )
    begin
      TZInfo::Timezone.get(tz_name)
    rescue TZInfo::InvalidTimezoneIdentifier
      raise Invalid, "Timezone Unknown: #{$!.message}"
    end
  end
  
end # === helpers SwissClock
