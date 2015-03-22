#!/opt/ruby-enterprise-1.8.6-20080810/bin/ruby
#
#
#

#
# 1. Make sure this file is excutable.
# 2. Don't print anything or else it will be sent to sender of email as an error by "sendmail".
# 
remove_existing_cron = ARGV.pop

$KCODE = 'u'

require File.join(  File.expand_path(File.dirname(__FILE__)), 'current/config/config_it' )
BusyConfig.hosting_rails_setup

require 'timeout'
require 'net/http'
require 'uri'


def add_cron
    begin
        require 'rubygems'
        require 'cronedit'
        include CronEdit
        Crontab.Add  'check_mail', '*/5 * * * * /home/busynoi/busynoise/new_letter.rb -remove_cron'
    rescue LoadError
    rescue
    end
end


if remove_existing_cron
    begin
        require 'rubygems'
        require 'cronedit'
        include CronEdit
        Crontab.Remove  'check_mail'
    rescue LoadError
    rescue
    end
end



begin
    
    res = Timeout::timeout(15) {  |timeout_length|
                Net::HTTP.post_form(URI.parse('http://www.busynoise.com/new/letter/has/arrived/to/be/processed'), {'just'=>'saying', 'hello'=>':)'})
            }
    
    
rescue Timeout::Error # IMPORTANT: :rescue does not capture all exceptions. 
                                    # In order for Timeout::Error to be captured and ignored, you must explictly capture it
                                    # with "rescue Timeout::Error" because "rescue" alone is not enough.
        
        add_cron
        
        # Don't print any text or else it will be shown to sender of email.
        
rescue  # Don't do anything.
            # If there were errors, they will be mailed 
            # to BN Support by the Sinatra error handlers
        add_cron
        
        # Don't print any text or else it will be shown to sender of email.
        
end
