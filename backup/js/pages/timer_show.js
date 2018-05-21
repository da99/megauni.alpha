
// Safari does not give you access to the datastore during unload events so save them
//  every 5 seconds.
var main_loop_id  = 0;

var theBeeper = null;
var beeps_a3 = null;
var beeps_server = null;

var beeps_a3_options = {
  id: 'the_beeps_a3',
  url: 'http://megauni.s3.amazonaws.com/beeping.mp3',
  volume: 90, 
  onfinish: function() {  
    this.play();      
  },
  autoLoad: true,       // enable automatic loading (otherwise .load() will call with .play())
  stream: false,
  autoPlay: false,
  onload : function(stat) {
    theBeeper = ( (this.bytesLoaded < 1000 ) ? beeps_server : beeps_a3 );
  }
};
var beeps_server_options = {
  id: 'the_beeps_server',
  url: 'http://megauni.s3.amazonaws.com/beeping.mp3',
  volume: 90, 
  onfinish: function() {  
    this.play();      
  },
  autoLoad: true,       // enable automatic loading (otherwise .load() will call with .play())
  stream: false,
  autoPlay: false
};

// =====================================================
//              Set-up SoundManager 2
// =====================================================
soundManager.url = "/js/vendor/soundmanager2/swf/";
soundManager.debugMode = window.location.hostname == 'localhost';
soundManager.onerror = function() {
  // SM2 could not start, no sound support, something broke etc. Handle gracefully.
  alert('Something went wrong. Try reloading the page once or twice.'); // for example
}

soundManager.onload = function() {
  // SM2 is ready to go!
  beeps_a3 = soundManager.createSound(beeps_a3_options);
  beeps_server = soundManager.createSound(beeps_server_options); 
  
  //
  // Show content and hide loading message.
  //
  $('#loading').hide();
  $('#content').show();
    
  //
  // Start the clock.
  //
  main_loop_id = setInterval( function(){
    BigClock.next_second();
  }, 1000 );
  
  //
  // Attach unload events.
  //
  $(document).unload( function() { 
      clearInterval( main_loop_id  ); 
  } );  
   
}; // soundManager.onload





var BigClock = {

  month_names : ['Jan.', 'Feb.', 'Mar.', 'April', 'May', 'June', 'July', 'Aug.', 'Sept.', 'Oct.', 'Nov.', 'Dec.'],
  day_names   : ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  
  chop_off_milliseconds : function(orig_epoch_time){
                            return( parseInt(orig_epoch_time / 1000) * 1000 );
                          },                                  

  format_minutes    : function(date){ return( (date.getMinutes()<10) ? '0'+date.getMinutes() : date.getMinutes() );},
  format_meridian   : function(date){ return( (date.getHours()>12) ? 'P.M.' : 'A.M.'  ); },
  format_year       : function( date ){ 
                          /* based on function: takeYear from:  http://www.quirksmode.org/js/introdate.html#year */
                          var y = date.getYear() % 100;
                          return( y + ( (y < 38) ? 2000 : 1900 ) ); 
  },
  
  format_seconds : function(date){
      return date.getSeconds() + " " + ((date.getSeconds() == 1) ? 'sec.'  :  'secs.' );
    
  },
  
  format_hour : function( date ){ 
    if( date.getHours() < 1 ) 
      return 12;
      
    return (date.getHours() < 13) ? 
                date.getHours() : 
                date.getHours() % 12 ;

  },
  
  format_time : function( date ){
    return BigClock.format_hour(date) + 
            ':' +  BigClock.format_minutes(date) + 
            ' ' + BigClock.format_meridian(date) ;
  },
  
  format_date : function( date ) {
    return BigClock.month_names[date.getMonth()] + 
          ' ' + date.getDate() + 
          ', ' + BigClock.format_year(date);
  },
    
  next_second : function(){
      /*
          div( :id=>'big_clock' ) { 
            p.day "Saturday"
            p.date "Aug. 8, 2009"
            p.time  "3:03 PM" 
            p.seconds "22 seconds"
          }
      */  
      var right_now    = new Date();

      
      $('#big_clock p.seconds').html( BigClock.format_seconds(right_now) );
      $('#big_clock p.time').html(    BigClock.format_time(right_now) );
      $('#big_clock p.day').html(     BigClock.day_names[right_now.getDay()] );
      $('#big_clock p.date').html(    BigClock.format_date(right_now) );
            
        
  }, // === update
  
  play_buzzer : function( ) {
    if(theBeeper)
      theBeeper.play();
  },
  
  stop_buzzer : function( ) {
    if(theBeeper)
      theBeeper.stop();
  }

}; // === BigClock


var Instruct = {
  start_test : function(){
      BigClock.play_buzzer(); 
      Swiss.swap_display(this, '#stop_test'); 
      return false;
  },
  
  stop_test : function(){
      BigClock.stop_buzzer(); 
      Swiss.swap_display(this, '#start_test'); 
      return false;
  }
};

var Post = {
  // state
  // playing = 1
  // paused = 2
  // stopped = 3
  // checked = 4
  // xmarked = 5
  note : function(){
    var form = $('#create_note form');
    var new_egg = {};
    
    new_egg['headline'] = form.find('input[name=headline]').val();
    new_egg['details'] = form.find('textarea[name=details]').val();

    Swiss.log_it( new_egg );
    return false;
  },
  
  alarm : function(){
    var form = $('#create_alarm form');
    var new_egg = {};
    
    new_egg['hours']   = Swiss.parse_int( form.find('select[name=hours]').val()   );
    new_egg['minutes'] = Swiss.parse_int( form.find('select[name=minutes]').val() );   
    new_egg['am_pm']   = form.find('select[name=am_pm]').val() ;  
    
    new_egg['headline']   = form.find('input[name=headline]').val();
    new_egg['details'] = form.find('textarea[name=details]').val();
    
    new_egg['type']    = 'alarm';
    
    Swiss.log_it( new_egg );
    return false;
  },
  
  countdown : function(){
    var form = $('#create_countdown form');
    var new_egg = {};
    
    $.each(['days', 'hours', 'minutes', 'seconds' ], function(){
      new_egg[this] = Swiss.parse_int( form.find('input[name='+this+']').val() );
    });
    
    new_egg['headline'] = form.find('input[name=headline]').val();
    new_egg['details']  = form.find('textarea[name=details]').val();
    new_egg['type']     = 'countdown';
    
    Swiss.log_it( new_egg );
    
    return false;
  }
};

var EggClock = {

  epoch_units             : { 'days' : (24 * 60 * 60 * 1000), 'hours' : (60 * 60 * 1000), 'minutes' : (60 * 1000), 'seconds' : 1000},  
  storage_bin             : $([]),
  clock_already_started   : false,
  clock_js_id             : 0,
  
  ///////////////////////////////////////////////////////////////////////////////////////////
  
  
  ///////////////////////////////////////////////////////////////////////////////////////////
    
  is_it_zero_seconds      : function(dt) { return(  dt.getSeconds() < 1  ); },
  is_it_exactly_midnight : function(dt) { 
                                          return( dt.getHours() < 1 && dt.getMinutes() < 1 && dt.getSeconds() < 1 ); 
                                        },
                                        
  ///////////////////////////////////////////////////////////////////////////////////////////   
                                          

                                            
  ///////////////////////////////////////////////////////////////////////////////////////////   
                                    
  next_second : function(){
      //
      // Loop through each work and update.
      //
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

  start_buzzer : function(event_id){
                          this.storage_bin.include(event_id);
                          
                          // Stop the 'test' buzzer since we no longer need it.
                          if(event_id != 'test')
                            EggClock.stop_buzzer('test');
                          
                          soundManager.play(theBeeper.sID);
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
                              soundManager.stop(theBeeper.sID); // $('alarm_holder').set( 'html', '');
                              
                            return true;
                          }

}; // end EggClock
