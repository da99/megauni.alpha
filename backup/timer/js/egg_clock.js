var EggClock = {
  month_names           : ['Jan.', 'Feb.', 'Mar.', 'April', 'May', 'June', 'July', 'Aug.', 'Sept.', 'Oct.', 'Nov.', 'Dec.'],
  day_names               : ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  epoch_units             : { 'days' : (24 * 60 * 60 * 1000), 'hours' : (60 * 60 * 1000), 'minutes' : (60 * 1000), 'seconds' : 1000},  
  storage_bin              : $A([]),
  clock_already_started      : false,
  clock_js_id               : 0,
  
  ///////////////////////////////////////////////////////////////////////////////////////////
  
  before_start              : $A([]),
  after_start                 : $A([]),
  
  before_end                : $A([]),
  after_end                   : $A([]),
  
  before_next_second : $A([]),
  after_next_second    : $A([]),
  
  before_test_buzzer : $A([]),
  after_test_buzzer    : $A([]),
  
  ///////////////////////////////////////////////////////////////////////////////////////////
    
  is_it_zero_seconds      : function(dt) { return(  dt.getSeconds() < 1  ); },
  is_it_exactly_midnight : function(dt) { 
                                          return( dt.getHours() < 1 && dt.getMinutes() < 1 && dt.getSeconds() < 1 ); 
                                        },
                                        
  ///////////////////////////////////////////////////////////////////////////////////////////   
                                          
  chop_off_milliseconds : function(orig_epoch_time){
                                          return( parseInt(orig_epoch_time / 1000) * 1000 );
                                        },                                  
  format_month_name : function(date){ return( this.month_names[date.getMonth()] ); },
  format_day               : function(date){ return( this.day_names[date.getDay()  ] ); },
  format_minutes        : function(date){ return( (date.getMinutes()<10) ? '0'+date.getMinutes() : date.getMinutes() );},
  format_meridian       : function(date){ return( (date.getHours()>12) ? 'P.M.' : 'A.M.'  ); },
  format_year               : function( date ){ /* based on function: takeYear from:  http://www.quirksmode.org/js/introdate.html#year */
                                                var y = date.getYear() % 100;
                                                return( y + ( (y < 38) ? 2000 : 1900 ) ); 
                                        },  
  format_12hour         : function( date_or_hour ){ 
                                                    var orig_hour = ( (date_or_hour).getHours ) 
                                                              ? date_or_hour.getHours() 
                                                              : parseInt(date_or_hour);

                                                    var hour = ( orig_hour < 1 ) 
                                                          ? 12 
                                                          :  ( (orig_hour < 13) ? orig_hour : orig_hour % 12 );

                                                    return hour;

                                            },
                                            
  ///////////////////////////////////////////////////////////////////////////////////////////   
  
  start                         : function(){ 
                                        Swiss.call_these_funcs( this.before_start);
                                        this.clock_js_id = setInterval( function(){ EggClock.next_second(); }, 1000 );
                                        Swiss.call_these_funcs( this.after_start );
                                    },
  end                           : function(){ 
                                        Swiss.call_these_funcs( this.before_end );
                                        clearInterval( EggClock.clock_js_id ); 
                                        Swiss.call_these_funcs( this.after_end );
                                    },
                                    
  next_second : function(){

                          // Do callbacks. /////////////////////////////////////////////////////////////////
                          Swiss.call_these_funcs( this.before_next_second );
                          /////////////////////////////////////////////////////////////////////////////////////////
                          
                          var right_now              = new Date();
                          var secs_now              = right_now.getSeconds();
                          var secs_now_str        = (secs_now == 1) ? 'sec.'  :  'secs.' 
                          
                          $('big_seconds').set( 'html',  ' ' + right_now.getSeconds() + " " + secs_now_str );


                          // Update hour...
                          if( !EggClock.clock_already_started || EggClock.is_it_zero_seconds(right_now) )
                            $('big_hour').set( 'html',  EggClock.format_12hour(right_now) + ':' + EggClock.format_minutes(right_now) + ' ' + EggClock.format_meridian(right_now)  );

                          // Update date...
                          if( !EggClock.clock_already_started ||  EggClock.is_it_exactly_midnight(right_now) )
                            $('big_date').set( 'html',   EggClock.format_day(right_now) + ' - ' + EggClock.format_month_name(right_now) + ' ' + right_now.getDate() + ', ' + EggClock.format_year(right_now)  );
                          
                          
                          // Make sure next time this function is called, it knows it is not the
                          //  first time.
                          EggClock.clock_already_started = true;
                          
                          // Finish callbacks. //////////////////////////////////////////////////////////////
                          Swiss.call_these_funcs( this.after_next_second );
                          ////////////////////////////////////////////////////////////////////////////////////////////
                          
                        }, // end next_second



  get_difference_in_units    : function(beginning_epoch, ending_epoch) {

                                              var units = { 'days' : 0, 'hours' : 0 , 'minutes' : 0, 'seconds' : 0 , 't_sign' : '-', 'times_up' : false};
                                              var earliest     = ( beginning_epoch < ending_epoch ) ? beginning_epoch : ending_epoch;
                                              var latest       = ( beginning_epoch < ending_epoch ) ? ending_epoch : beginning_epoch;
                                              units['t_sign']      = ( beginning_epoch <= ending_epoch ) ? '-' : '';
                                              units['times_up']   = ( ending_epoch <= beginning_epoch );
                                              
                                              var difference = latest - earliest;

                                              // days
                                                units['days'] = parseInt( difference / this.epoch_units['days']  ) ;
                                              // hours
                                                difference =  difference - ( this.epoch_units['days'] * units['days'] );
                                                units['hours'] =  parseInt( difference / this.epoch_units['hours'] ) ;
                                              // minutes 
                                                difference = difference - ( this.epoch_units['hours'] * units['hours']);
                                                units['minutes'] = parseInt( difference / this.epoch_units['minutes'] );
                                              // seconds
                                                difference = difference - ( this.epoch_units['minutes'] * units['minutes'] );
                                                units['seconds'] = Math.ceil( difference / this.epoch_units['seconds'] );

                                              units['invalid'] = !( $chk(units['days']) && $chk(units['hours']) && $chk(units['minutes']) && $chk(units['seconds']) );

                                              return units;

                                              },
  cache_buzzer : function(){
                                if(this.storage_bin.length > 0)
                                  return false;  
                                var player_html = (Browser.Engine.trident) ? 
                                                            '' : 
                                                            '<p class="cached_buzzer">*<object  type="application/x-shockwave-flash" data="/eggs/js/vendor/button_player/button/musicplayer_f6.swf?&autoplay=false&repeat=false&song_url=http://megauni.s3.amazonaws.com/beeping.mp3"  width="43"  height="20" > <param name="movie"  value="/eggs/js/vendor/button_player/button/musicplayer_f6.swf?&autoplay=true&repeat=false&song_url=/eggs/js/beeping.mp3" /><img src="/eggs/js/vendor/loading.gif" width="43" height="11" alt="*" /></object></p>';
                                                        
                                $('alarm_holder').set( 'html', player_html);
                                return true;
                            },
  start_buzzer : function(event_id){
                          var alarm_needs_2b_drawn = this.storage_bin.length < 1;
                          this.storage_bin.include(event_id);
                          
                          if(event_id != 'test')
                            EggClock.stop_buzzer('test');
                          else
                            Swiss.call_these_funcs( this.before_test_buzzer);
                          
                          // add alarm to DOM.
                          if($('EggClock_alarm'))
                            return false;
                          
                          soundManager.play('the_beeps');
                          return $('alarm_holder');
                          
                          var player_html = '';

                          if(Browser.Engine.trident) {

                            player_html = '* *<bgsound loop="25" SRC="http://megauni.s3.amazonaws.com/beeping.wav" />';

                          } else {
                          
                            player_html += '    <p>*';
                            player_html += '      <object  type="application/x-shockwave-flash" data="/eggs/js/vendor/button_player/button/musicplayer_f6.swf?&autoplay=true&repeat=true&song_url=http://megauni.s3.amazonaws.com/beeping.mp3"  width="43"  height="20" >';
                            player_html += '       <param name="movie"  value="/eggs/js/vendor/button_player/button/musicplayer_f6.swf?&autoplay=true&repeat=true&song_url=http://megauni.s3.amazonaws.com/beeping.mp3" />';
                            player_html += '       <img src="/eggs/js/vendor/loading.gif" width="43" height="11" alt="*" />';
                            player_html += '      </object>';
                            player_html += '    </p>';

                          };

                          if( alarm_needs_2b_drawn )
                            $('alarm_holder').set( 'html', player_html);
                          return $('alarm_holder');
                    },
  stop_buzzer : function(event_id){
  
                            if(this.storage_bin.length < 1)
                              return false;
                              
                            if(event_id !='test' && this.storage_bin.length ==1 && this.storage_bin[0]=='test' )
                              return false;
                              
                            if(event_id=='test')
                              Swiss.call_these_funcs( this.after_test_buzzer);

                            this.storage_bin.erase(event_id);
                            this.storage_bin.erase('test');

                            
                            if(this.storage_bin.length < 1  )
                              soundManager.stop('the_beeps'); // $('alarm_holder').set( 'html', '');
                              
                            return true;
                          }

}; // end EggClock
