require 'rack'
require 'rack/utils'
require 'controls/Control_Base'


class The_App
  
  Redirect      = Class.new(StandardError)
  HTTP_404      = Class.new(StandardError)
  
  # ======== CLASS stuff ======== 

	module Options
		ENVIRONS = [:development, :production, :test]
	end

  Options::ENVIRONS.each { |envi|
    eval %~
      def self.#{envi}?
        ENV['RACK_ENV'] == '#{envi}'
      end
    ~
  }

  def self.non_production?
    !['production', 'staging'].include?(ENV['RACK_ENV'])
  end

  def self.environment
    ENV['RACK_ENV']
  end

  def self.controls
    @controls ||= []
  end

  #
  # NOTE: 
  # For Thread safety in Rack, no instance variables should be changed.
  # 
  def self.call(new_env)

    control, action_method, args = new_env['the.app.meta'].values_at(:controller, :action_method, :args)
    
    the_app = new_env['the.app'] = control.new(new_env)
    begin
      the_app.send( action_method, *args )
    rescue The_App::Redirect
    end
    the_app.response.finish
    
  end


end # === The_App



__END__

module Bunny_Cache_Controller

  # Specify response freshness policy for HTTP caches (Cache-Control header).
  # Any number of non-value directives (:public, :private, :no_cache,
  # :no_store, :must_revalidate, :proxy_revalidate) may be passed along with
  # a Hash of value directives (:max_age, :min_stale, :s_max_age).
  #
  #   cache_control :public, :must_revalidate, :max_age => 60
  #   => Cache-Control: public, must-revalidate, max-age=60
  #
  # See RFC 2616 / 14.9 for more on standard cache control directives:
  # http://tools.ietf.org/html/rfc2616#section-14.9.1
  def cache_control(*values)
    if values.last.kind_of?(Hash)
      hash = values.pop
      hash.reject! { |k,v| v == false }
      hash.reject! { |k,v| values << k if v == true }
    else
      hash = {}
    end

    values = values.map { |value| value.to_s.tr('_','-') }
    hash.each { |k,v| values << [k.to_s.tr('_', '-'), v].join('=') }

    response['Cache-Control'] = values.join(', ') if values.any?
  end

  # Set the Expires header and Cache-Control/max-age directive. Amount
  # can be an integer number of seconds in the future or a Time object
  # indicating when the response should be considered "stale". The remaining
  # "values" arguments are passed to the #cache_control helper:
  #
  #   expires 500, :public, :must_revalidate
  #   => Cache-Control: public, must-revalidate, max-age=60
  #   => Expires: Mon, 08 Jun 2009 08:50:17 GMT
  #
  def expires(amount, *values)
    values << {} unless values.last.kind_of?(Hash)

    if amount.respond_to?(:to_time)
      max_age = amount.to_time - Time.now
      time = amount.to_time
    else
      max_age = amount
      time = Time.now + amount
    end

    values.last.merge!(:max_age => max_age)
    cache_control(*values)

    response['Expires'] = time.httpdate
  end

  # Set the last modified time of the resource (HTTP 'Last-Modified' header)
  # and halt if conditional GET matches. The +time+ argument is a Time,
  # DateTime, or other object that responds to +to_time+.
  #
  # When the current request includes an 'If-Modified-Since' header that
  # matches the time specified, execution is immediately halted with a
  # '304 Not Modified' response.
  def last_modified(time)
    time = time.to_time if time.respond_to?(:to_time)
    time = time.httpdate if time.respond_to?(:httpdate)
    response['Last-Modified'] = time
    halt 304 if time == request.env['HTTP_IF_MODIFIED_SINCE']
    time
  end

  # Set the response entity tag (HTTP 'ETag' header) and halt if conditional
  # GET matches. The +value+ argument is an identifier that uniquely
  # identifies the current version of the resource. The +kind+ argument
  # indicates whether the etag should be used as a :strong (default) or :weak
  # cache validator.
  #
  # When the current request includes an 'If-None-Match' header with a
  # matching etag, execution is immediately halted. If the request method is
  # GET or HEAD, a '304 Not Modified' response is sent.
  def etag(value, kind=:strong)
    raise TypeError, ":strong or :weak expected" if ![:strong,:weak].include?(kind)
    value = '"%s"' % value
    value = 'W/' + value if kind == :weak
    response['ETag'] = value

    # Conditional GET check
    if etags = env['HTTP_IF_NONE_MATCH']
      etags = etags.split(/\s*,\s*/)
      halt 304 if etags.include?(value) || etags.include?('*')
    end
  end


end  # === module Bunny_Cache_Controller

module Bunny_Callers


  def dump_errors!(boom)
    trace = boom.backtrace
    backtrace = begin
                  unless settings.clean_trace?
                    trace
                  else
                    trace.reject { |line|
                      line =~ /lib\/sinatra.*\.rb/ ||
                        (defined?(Gem) && line.include?(Gem.dir))
                    }.map! { |line| line.gsub(/^\.\//, '') }
                  end
                end

    msg = ["#{boom.class} - #{boom.message}:",
      *backtrace].join("\n ")
    @env['rack.errors'].puts(msg)
  end
  CALLERS_TO_IGNORE = [
    /custom_require\.rb$/ # rubygems require hacks (Solution from Sinatra)
  ]

  # add rubinius (and hopefully other VM impls) ignore patterns ...
  CALLERS_TO_IGNORE.concat(RUBY_IGNORE_CALLERS) if defined?(RUBY_IGNORE_CALLERS)

  def clean_backtrace
    caller(1).
      map    { |line| line.split(/:(?=\d|in )/)[0,2] }.
      reject { |file,line| CALLERS_TO_IGNORE.any? { |pattern| file =~ pattern } }
  end

end # === Bunny_Callers -----------------------------------------------------


































__END__



Mini-Newspaper (for each life, each gets a custom debate page.)
  - Posts
    - view_id 
      1 - Public
      2 - Friends
      3 - Friends & Fans
      4 - Let me select audience:
  - PostComments [ "Important News", "A Random Thought"]
  - PostQuestions [ "Important Question", "A Silly Question" ]
  - PostViewers
  - club_id
  |
Network
  - TightPersons
  - LoosePersons
  - TightPersonInvite
  |
Clubs
  - TodoLists
  - Predictions
  - Questions
  - News (Debates)
  |
TODOS
  |
Pets
  |
Questions 
  |
Translation
  - to English
  - to Japanese
  |
Lunch Dating
  Find Breeder
  Find Partner
  Complain
  Advice/Tips/Warnings
  |
Housing
  Rent Out
  Find
  Mice
  Cleaning
  |
University
  Rate Professors
  Post Warnings/News
  Find/Create A College
  |
Blogs + Newspaper
  |
Travel & Dining
  Find a city
  Post a city
  |
News
  |
Layman Encyclopedia/Search (=Brain)
(Unify Wikipedia-Clone with Google-clone + Bing clone)
  |
Corporal Captitalists (bonds in working individuals)





# ------- TABLES ---------------------
NewsComments
  - news_id
  - status = PENDING || ACCEPTED || REJECTED
  - category = PRAISE || DENOUNCE || FACT CHECK || QUESTION || RANDOM
  - parent_id # for answering questions posted in the comments.
NewsCommentSections

News
  - parent_id # for news branching (predictions or responses).
  - language_id
  - category = DOINGS || NEWS || PREDICTIONS || OPINIONS || QUESTIONS
NewsEdits  




- version 1
  - site permission levels
    - admin
    - editor/moderator
    - unlimited invitations
  - multiple identities
  - pet profiles
    - med condition
  - baby profiles
    - med condition
  - pre-born profiles
    - names
  - fictional profiles
  - photo management
  - youtube linking
  - photo linking
  - guides/pamphlets
  - people mananagement
    - birthdays, anniversaries, important dates, repeating dates

  - Q&A
    - translations
    - vote best answer
    - competance weights
    
    
  - daily and onetime checklists
    - vitamins, etc.
    - countdowns, but no sound  
    - sharable
    - rules-based  
  - project management
    - due dates
      - status
    - milestones
    - files
  - office management
    - tweets
      - labels   
    - news
    - calendar
    - vote for best answer
      - translation
      - gardening
      - engineering
      - etc. 
      
  - invitations
    - gender
    - group
    
  - following
    - friends
    - fans
    - family
    - co-workers
    - frienemies
    - enemies
    - ex-lovers
    
  - tweets with labels   
    - No SMS for now.
   
    
    
- Future version   
  - bug tracking
  - visualize data stream (help handle data overload)
    - inspiration: plurk
  - email broadcasting
    - newsletters paid for 250 or above
  - video management
  - community management 
  - YouTube account connection  
  - Market 
    - local services
      - cleaning
      - food delivery  

  - reputation
    - import/export  
   
  - footprints
    - request to see profile
    - freind only profiles
  
  - universal language

- Create stories for learning alphabet and kanji characters
  - Video.
  - Slides.
- Vote on translations.
- Vote on pronounciation. (MP3/OggVorbis)


Future 
- Job board.
- Advice/Help section
- News section
- Video news w/translation.
- Postcard to Bill Sardi.     
