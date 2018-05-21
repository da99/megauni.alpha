$(window).addEvent('load', function(){

  /*
  var eggs1 = Cookie.read('eggs');
  Cookie.dispose('eggs');
  
  var eggs2 = Cookie.read('eggs');
  Cookie.dispose('eggs', { path :  '/' });
  
  var eggs3 = Cookie.read('eggs');
  Cookie.dispose('eggs', { path : '/busy-noise' });
 
  var eggs4 = Cookie.read('eggs');
  Cookie.dispose('eggs', { path : '/busy-noise/' });
  
  
  var last_eggs =  eggs4 || eggs3 || eggs2 || eggs1 || JSON.encode({}) ;
  Cookie.write( 'eggs', last_eggs, {duration : 30 }) ;
  */
  
  //
  // Show 'Add Stuff'
  //
  $('add_stuff').set('styles', { display : 'block', visibility : 'visible'});
  
  //
  // Re-write email to a more user friendly format.
  //
  var new_email = '';
  $$('#instructions div.about span.addr').each(function(email_span){
                                                                          if(email_span.get('html')) {
                                                                            new_email = email_span.innerHTML.replace(' [at] ', '@').replace(' [dot] ', '.');
                                                                            email_span.set( 'html', '<a href="mailto:'+new_email+'" title="Send me bug reports.">'+new_email+'</a>' );
                                                                          };
                                                                        });
  
  //
  // Set up callbacks for EggClock
  //
  var show_work_ele = function(){ $('work').set('styles', {display : 'block', visibility : 'visible' })};
  EggClock.before_start.push(  Chicken.lay_all_eggs,  show_work_ele );
  EggClock.after_end.push(   Chicken.window_unload     );
  EggClock.after_next_second.push(   Chicken.see_if_any_hatched   );
  
  EggClock.before_test_buzzer.push( function(){ $('instructions').addClass('testing_buzzer'); } );
  EggClock.after_test_buzzer.push( function(){  $('instructions').removeClass('testing_buzzer');  });
  
  //
  // Start the clock.
  //
  EggClock.start();
  EggClock.cache_buzzer();
  
}); //  window.addEvent 'load' 


window.addEvent('unload', function(){ EggClock.end(); });


