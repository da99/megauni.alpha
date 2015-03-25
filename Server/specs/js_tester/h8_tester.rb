

require 'yaml'

before do
  H8Tester.check_expect_page_load(request)
end

helpers do
  def render_this(file)
      content = erb(file)
      H8Tester.insert_suite( request, content )
  end
end

get "/h8_start" do
    # Check if H8Tester is brand new.
    if H8Tester.started?
        # --- Tell user to restart web server if not.
        render_this(:restart_the_server)
    else
        # --- Load tests and create instance ID for each one.
        # ------ Print link to next test.
        next_suite = H8Tester.next_suite
        raise "No H8 tests found." if !next_suite
        render_this(:h8_start)
    end # if/else

end # === get "/h8_start"

post "/h8_expect_page_load" do
    H8Tester.expect_page_load( params )
    'saved'
end # ===

post "/h8_save_results" do
    # Check if the results came in properly.
    puts ">>>> H8 results \n #{params.inspect}"
    if !params['the_results'] || ( params['the_results'] && params['the_results'].empty? )
        H8Tester.errors << "ERROR: No Results returned for: \n #{params.inspect}"
    else
        # Find test.
        the_test = H8Tester.suites[params['suite_id']]
        if !the_test
            H8Tester.errors << "ERROR: Test not found: #{params['suite_id'].inspect}"
        else
            # Add results to test.
            if the_test[:results]
                H8Tester.errors << "#{the_test[:name]} (#{the_test[:id]}) already has :results set."
            else
                the_test[:results] = params['the_results']
                # Send back message.
                if H8Tester.next_suite
                    "NEXT TEST: #{H8Tester.next_suite[:path]}"
                else
                    "NO MORE TESTS"
                end
             end
        end
    end
end # === post "/h8_save_results"

get "/h8_results" do
    @failed_tests = H8Tester.suites.values.map { |suite| suite[:results] || [] }.flatten.select {|test| !test['pass'] }
    @the_title = case failed_tests.size
        when 0
            "All Pass"
        when 1
            "1 Failed Test"
        else
            "#{failed_tests} Fails"
    end
    render_this(:h8_results )

end # === get '/h8_results'






get '/' do
    render_this(:homepage)
end

get '/about_site' do
    render_this(:about_site)
end

get '/about_us' do
    render_this(:about_us)
end




class H8Tester

  def self.errors
      @errors ||= []
  end

  def self.started?
      @begun
  end

  def self.start
      raise "H8Tester can only be started once" if @begun
      @begun = 1
  end

  def self.suite_order
      __load_suites__ if !@suite_order
      @suite_order
  end

  def self.suites
      @suites
  end

  def self.check_expect_page_load(request)
      return nil if !request.get?
      return nil if !@expecting_page_load

      test = find_test(@expecting_page_load[:suite_id], @expecting_page_load[:test_id] )
      if !test
          raise "H8 Test not found: #{@expecting_page_load[:suite_id].inspect}, #{@expecting_page_load[:test_id].inspect}"
      end
      test['actual'] = request.path_info
      test['pass'] = test['actual'] == test['expected']
      @expecting_page_load = nil
      test['pass']
  end

  def self.find_test(suite_id, test_id)
          suite = suites[ suite_id ]
          return nil if !suite
          suite[:results].detect { |current_test| current_test['id'] ==  test_id }
  end

  def self.expect_page_load( params )
      if @expecting_page_load
          test = find_test( @expecting_page_load[:suite_id], @expecting_page_load[:test_id] )
          test['actual'] = "nil"
          test['pass'] = false
          @expecting_page_load  = nil
      end
      suite = H8Tester.suites.values.detect { |suite| suite[:id] == params['suite_id'] }
      raise "ERROR: SUITE NOT FOUND: #{params.inspect}" if !suite

      if suite[:results]
          raise "ERROR: Suite results already set: #{params.inspect}"
      end

      @expecting_page_load = { :suite_id=>params['suite_id'],
                                                    :expected=>params['expected'],
                                                    :test_id=> params['test_id']   }
  end


  def self.__load_suites__
      start unless started?
      @suites ||= begin
          @suite_order ||= []
          the_suites = {}
          Pow!("specs/js").each { |file|
              if file.file? && file =~ /\.js\z/ && file =~ /^[0-9]+/

                  content = file.read

                  content =~ /PATH\:\ +(.+)\z/
                  raise "'PATH:' not found in JS suite file: #{file}" if !$1
                  path = $1.to_s.strip

                  content =~ /NAME\:\ +(.+)/
                  suite_name = ($1 || "No Name").to_s.strip

                  suite_id = File.basename(file)
                  @suite_order << suite_id

                  the_suites[ suite_id ] =  {  :path=>path,
                                                          :name => suite_name,
                                                          :content=>content,
                                                          :id =>suite_id ,
                                                          :runs => 0,
                                                          :results => nil,
                                                          :errors => [] }
              end
          }
          the_suites
      end
  end # === self.suites

  def self.next_suite
      next_suite_id = suite_order.detect { |suite_id|
          suites[suite_id][:results].nil?
      }
      return nil if !next_suite_id
      suites[ next_suite_id ]
  end

  def self.insert_suite(request, content)
      the_suite = self.next_suite
      return content if !next_suite

      jquery = content[/\/jquery[a-z0-9\.\-]{1,}\.js/] ?
                          '' :
                          %~
                              <script src="/js/vendor/jquery.1.3.2.min.js" type="text/javascript"></script>
                          ~.strip ;

      content.sub( /\<\/body\>/i, %~
          #{jquery.strip}
          <script src="/js/h8_tester.js" type="text/javascript"></script>
          <script type="text/javascript">
              var h8_tests = [];
              var h8_suite_id = "#{the_suite[:id]}";
              var h8_suite_name = "#{the_suite[:name]}";
              $(window).load( function(){
                  #{the_suite[:content]}
                  h8_run( h8_tests );
              });
          </script>
          <body>
      ~)
  end

end # === H8Tester

