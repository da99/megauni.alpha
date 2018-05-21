var Chicken = {
  rookery_size : 3000,
  eggs :  $H({}) ,
  eggs_properly_retrieved_from_storage : false,
  
  storage_bin : {
    'highlight_start' : '#073D6F',
    'highlight_end'   : '#FFFF99'
  },
  
  get_egg_id : function(egg){
                          return( 'task_' + (new Date(parseInt(egg.created_at))).getTime() + '' + Chicken.eggs.getLength() );
                        },

  boring_task_count : 0,
  get_boring_task_count : function(){
                          if(Chicken.boring_task_count==0)
                            Chicken.boring_task_count = Chicken.eggs.getLength();
                          Chicken.boring_task_count +=1;
                          return Chicken.boring_task_count;
                        },
  lay_all_eggs : function() {                              
                              // Add actions for forms used to create new eggs.
                              $first('#create_countdown form button.save').onclick = function(){ Chicken.create_countdown($(this).getParent('form')); return false;}; 
                              $first('#create_alarm form button.save').onclick = function(){ Chicken.create_alarm($(this).getParent('form')); return false;}; 
                              $first('#create_note form button.save').onclick = function(){ Chicken.create_note($(this).getParent('form')); return false;};  
                              
                              // Stop form from being submitted.
                              $$('#create_countdown form', '#create_alarm form', '#create_note form').each(function(form){
                                                                                                                                  form.onsubmit = function(){return false}; 
                                                                                                                                });            
                              
                              // Get non-deleted eggs from storage.
                              var stored_eggs = Cookie.read('eggs') ? $H( JSON.decode(Cookie.read('eggs')) ) : $H({});
                              Chicken.eggs      = stored_eggs.filter(function(egg, egg_id){ 
                                                                                            return(egg['status'] != 'deleted');
                                                                                          });
                                                                                          
                              Chicken.eggs_properly_retrieved_from_storage  = true;
                              
                              // Go through each egg, (reversed order to keep original order ), and update values as necessary.
                              Chicken.eggs.getKeys().sort(function(a,b){ 
                                    // return a.substitute({'task_':''})-b.substitute({'task_':''});
                                    return (parseInt(a.substitute({'task_':''})) || 0 )- ( parseInt(b.substitute({'task_':''})) || 0 );
                                    }
                                    
                                    ).each(function(egg_id){                   
                                      var egg = Chicken.eggs[egg_id];
                                      
                                      // Set boring task count.
                                      var boring_headline = 'Boring Task #';
                                      if(egg['headline'].contains(boring_headline) && egg['headline'].length > boring_headline.length) {
                                      
                                        var num_str = egg['headline'].substring( boring_headline.length , egg['headline'].length)
                                        var num = parseInt(num_str);
                                        if(num > Chicken.boring_task_count) {
                                          Chicken.boring_task_count = num;
                                          
                                        };
                                      };
                                      
                                       // ****************************************************************************
                                       // See if  :ignore_buzzer needs to be set.
                                       // ****************************************************************************
                                       var current_get_time             = (new Date()).getTime(); 
                                       var alarm_has_ended            = ( egg['category'] == 'alarm' && egg['ends_at'] && egg['ends_at'] < current_get_time ) &&
                                                                                        (egg['status'] == 'at_play' || egg['status'] == 'times_up');
                                       
                                       var countdown_has_ended   = ( egg['category'] == 'countdown' && egg['status'] == 'times_up' );
                                       

                                      egg['ignore_buzzer'] = ( alarm_has_ended || countdown_has_ended ) ? 
                                                                          true : 
                                                                          false; 

                                       // ****************************************************************************                                
                                      Chicken.lay_egg(egg);
                                        
                                
                              });
                            }, // end lay_all_eggs
  
  /* Returns: reference to egg.
  */
  lay_egg   : function(egg, ele_inject_before){                       
                       if( egg['status'] == 'deleted' ) {
                        return false;
                       };
                      
                      EggClock.stop_buzzer('test');
                      
                      // Clone egg canister.
                      var canister = $first('#dom_templates div.egg_template_'+egg['category']).clone();
                      canister.set('id', egg['id'] );
                      // Attach egg to canister.
                      canister.store('egg', egg);

                      // Send new canister to the DOM.
                      // Elements must be in the DOM for certain methods ($$) to work properly.
                      if(ele_inject_before)
                        canister.inject(ele_inject_before, 'before');
                      else
                        canister.injectTop( $('work') );
                                            
                      // Add actions to buttons in egg templates.
                      $$( '#'+canister.id+' div.undo a',
                            '#'+canister.id+' div.control_panel div.buttons a', 
                            '#'+canister.id+' div.summary div.details_control_panel a').each(function(a_tag){
                           
                          a_tag.onclick             = function(){ 
                                                                      var egg_func_name = $(this).get('href').split('#')[1];
                                                                      Chicken[ egg_func_name  ]( $(this).getParent('div.egg') ); 
                                                                      return false; 
                                                              }
                      });
                      
                      // Add actions to buzzer option checkbox.
                      canister.getElements('div.buzzer_option input').each(function(checkbox){
                          checkbox.onclick = function(){ Chicken.egg_ringer_option_changed(checkbox); return true; }
                      });
                      
                      // Show/Hide details.
                      if(egg['details'].trim().length==0)
                        canister.addClass('no_details');
                        
                      if(egg['show_details'])
                        Chicken.egg_show_details(canister);
                      else
                        Chicken.egg_hide_details(canister);                      
                      
                      // Update text in canister.    
                      canister.getElement('h4').set('html', unescape(egg['headline']).nl2br() );
                      canister.getElement('div.details').set('html', unescape(egg['details']).nl2br() );                      
                      canister.getElement('span.short_headline').set( 'html',  egg['short_headline'] );
                      if(egg['use_timer']) {
                        canister.getElement('div.setting').set( 'html', egg['category'].capitalize() + ' - ' + Chicken.format_setting(egg) );   
                        // Update time statuss.
                        if(egg['status']=='paused'  ){
                          var diff_units = EggClock.get_difference_in_units( egg['starts_at'] , egg['ends_at']);
                          canister.getElement('div.time_status').set( 'html',  Chicken.format_time_status( diff_units  ) );     
                        };                          
                      };
                      
                      // Update buzzer option.
                      if(egg['use_timer']){
                        canister.getElement('div.buzzer_option input').checked = (egg['use_buzzer']) ? true : false;
                        Chicken.egg_ringer_option_changed( canister.getElement('div.buzzer_option input') );                        
                      };
                      
                      // Pause this egg if it was previously playing and if it's a countdown..
                      Chicken.egg_unclean_paused(canister);
                      
                      // Update canister.
                      Chicken['egg_' + egg['status']]( canister );
                      
                      
                      return egg;
                    }, // end function

  ///////////////////////////////////////////////////////////////////////////////////////////////

  format_time_status : function( egg_or_time_unit_hash ){ // time_unit_hash is based on EggClock.get_difference_in_units

                                        var time_unit_hash = ( egg_or_time_unit_hash['category'] ) 
                                                    ? EggClock.get_difference_in_units(egg_or_time_unit_hash['starts_at'], egg_or_time_unit_hash['ends_at']) 
                                                    : egg_or_time_unit_hash;

                                        if(time_unit_hash['times_up']) 
                                          return '<span class="number">Time\'s up.</span>' ;


                                        var status_string = '<span class="number">'+time_unit_hash['t_sign']+'</span>';


                                        // days
                                        if(time_unit_hash['days'] != 0 ) {
                                          status_string += '<span class="number">'+time_unit_hash['days']+'</span>' ;
                                          status_string += '<span>days</span>';

                                        };


                                        // hours
                                        if(time_unit_hash['days'] > 0 || time_unit_hash['hours'] > 0) {
                                          status_string += '<span class="number">'+time_unit_hash['hours']+'</span>' ;
                                          status_string += '<span>hr</span>';
                                        };


                                        // minutes
                                        if(time_unit_hash['days'] > 0 || time_unit_hash['hours'] > 0 || time_unit_hash['minutes'] > 0 ) {
                                          status_string += '<span class="number">'+time_unit_hash['minutes']+'</span>' ;
                                          status_string += '<span>min</span>';
                                        };


                                        // seconds
                                        status_string += '<span class="number">'+time_unit_hash['seconds']+'</span>';
                                        status_string += '<span>sec</span>';

                                        return status_string;
                                        
                                      },


  format_setting : function(egg_hash){ 

                                switch(egg_hash['category']){

                                  case 'alarm':

                                    return EggClock.format_12hour(egg_hash['hours']) + 
                                      ( (egg_hash['minutes'] == 0) ? ' ' : (':' + egg_hash['minutes'] + ' ' ) ) + 
                                      ( (egg_hash['am_pm']=='am') ? 'A.M.' : 'P.M.' );

                                    break;

                                  case 'countdown':

                                    var setting_in_words = $A([]);

                                      if(egg_hash['days'] != 0 ) 
                                        setting_in_words.include( egg_hash['days'] + ' days' );
                                        
                                      if(egg_hash['hours'] != 0 )
                                        setting_in_words.include( egg_hash['hours'] + ' hrs' );

                                      if(egg_hash['minutes'] != 0 )
                                        setting_in_words.include( egg_hash['minutes'] + ' mins' );

                                      if(egg_hash['seconds'] != 0 )
                                        setting_in_words.include( egg_hash['seconds'] + ' secs' );

                                      return setting_in_words.join(', ')

                                    break;

                                };

                              }, // end function

  calculate_ends_at : function(egg_hash) {
                                                      var right_now = new Date();
                                                      var right_now_without_milliseconds = new Date( Date.parse( right_now.toLocaleString() ) );


                                                      if( egg_hash['category'] == 'countdown' ) {
                                                        var time_in_milli_seconds = ( (egg_hash['days'] * 24 * 60 * 60) + (egg_hash['hours'] * 60 * 60) + (egg_hash['minutes'] * 60) + egg_hash['seconds'] ) * 1000;
                                                        return(right_now.getTime() + time_in_milli_seconds);
                                                      }; // end countdown


                                                      if( egg_hash['category'] == 'alarm' ) {

                                                        if( right_now.getHours() > egg_hash['hours'] || 
                                                            ( right_now.getHours() == egg_hash['hours'] && right_now.getMinutes() >= egg_hash['minutes']) 
                                                          ) {

                                                          // Alarm is for tomorrow
                                                          var tomorrow = new Date( (right_now.getTime()) + (24 * 60 * 60 * 1000 ) );
                                                          tomorrow.setHours( egg_hash['hours'] );
                                                          tomorrow.setMinutes( egg_hash['minutes'] );
                                                          tomorrow.setSeconds(0);

                                                          return( (new Date(Date.parse(tomorrow.toLocaleString()))).getTime() );

                                                        } else { // Alarm is for later today.

                                                          var near_future = new Date();
                                                          near_future.setHours( egg_hash['hours'] );
                                                          near_future.setMinutes( egg_hash['minutes'] );
                                                          near_future.setSeconds( 0 );

                                                          return( (new Date(Date.parse(near_future.toLocaleString()))).getTime() );

                                                        };

                                                      }; // end alarm


                                                    }, // end calculate_ends_at

  ///////////////////////////////////////////////////////////////////////////////////////////////

  see_if_any_hatched : function(){

                                          // Go through each egg to see which ones are :playing or :paused.
                                          // Update the DOM when neccessary.
                                          Chicken.eggs.each(function(egg, index){
                                          
                                              if(egg['status']!='times_up'){ 
                                                EggClock.stop_buzzer(egg['id']);
                                              };                                         
                                               
                                            switch(egg['status']){                                                
                                              case 'at_play':
                                                
                                                var canister = $(egg['id']) ;
                                                var diff_units = EggClock.get_difference_in_units( egg['starts_at'], egg['ends_at']);
                                                
                                                if(diff_units['invalid']){
                                                  Chicken.egg_ready_to_start(egg);
                                                };
                                                
                                                if(diff_units['times_up']){ // this egg has hatched!  Quick, tell the farmer!
                                                  Chicken.egg_times_up( canister  );
                                                } else { // move egg closing to hatching.
                                                  // bring it closer to :ends_at
                                                  egg['starts_at'] = (new Date()).getTime(); 
                                                  canister.getElement('div.time_status').set( 'html',  Chicken.format_time_status( diff_units ) );
                                                };
                                                break;
                                            }; // end switch

                                          });

                                        }, // end function
  
  save_eggs : function(new_egg){

                          if( new_egg && !Chicken.see_if_egg_fits_in_rookery(new_egg) ) {
                            if(Chicken.eggs.getKeys().length > 0) {
                              alert('Not enough memory to store new ' + new_egg['category'] + ".\n" +
                                          'Try deleting some of your tasks and then try saving this ' + new_egg['category'] + ' again.');
                              return false;
                            } else {
                              alert("This " + new_egg['category'] + " is too big to be saved to the computer. \n"+
                                       "You can use it for now, but if you RELOAD the page it will DISAPPEAR like the value of the US dollar.");
                            };

                            
                          };
                          
                          // Add it to the rookery.
                          if(new_egg) {
                            Chicken.eggs.include( new_egg['id'], new_egg );
                          };
                          
                          Cookie.write( 'eggs', JSON.encode(Chicken.eggs), {duration : 30} );
                          
                          return true;
                      }, // end save_eggs

  see_if_egg_fits_in_rookery : function(new_egg) {

        // Create temp. rookery.
        var temp_rookery = $H({});
        var egg_ids_to_obliterate = $A([]);
    
        Chicken.eggs.each(function(egg, egg_index){
                                          temp_rookery[egg_index] = egg;
                                        });
        
        // Add new egg to temp rookery.
        temp_rookery.include(new_egg['id'], new_egg);
      
        // Check size of temp rookery.
        if( JSON.encode(temp_rookery).length > Chicken.rookery_size ) {
          // Take out any deleted eggs if size too big.
          temp_rookery = temp_rookery.filter(function(egg, egg_index){ 
                                                                        if(egg['status']=='deleted')
                                                                          egg_ids_to_obliterate.include(egg['id']);
                                                                          
                                                                        return (egg['status'] != 'deleted'); 
                                                                      
                                                                      });
          
          // Obliterate deleted eggs.
          egg_ids_to_obliterate.each(function(egg_id){
                                                      Chicken.obliterate_egg(Chicken.eggs[egg_id]);
                                                    });
        }; // end checking size of temp rookery.
        
        // Return with Boolean.
        return (JSON.encode(temp_rookery).length <= Chicken.rookery_size);
  },

  window_unload : function(new_egg) {
  
                                            // If there is a bug that occurred before eggs were 
                                            // retrieved from storage (Cookie.read), then return.
                                            // If we save the default value (empty Hash), then all
                                            //  previous eggs would be erased because of the bug.
                                            if( !Chicken.eggs_properly_retrieved_from_storage )
                                              return false;
                                            
                                            // Filter out any deleted eggs to save space in cookie.
                                            Chicken.eggs = Chicken.eggs.filter(function(egg,egg_index){return egg['status'] != 'deleted';});
                                            
                                            // Compensate :ends_at for any time lost during page unload.
                                            // This is because visually the page stand stills, but the script continues for
                                            //  a second or two.
                                            Chicken.eggs.each(function(egg, egg_id){
                                                  if( egg['status']=='at_play' )
                                                      egg['ends_at'] += 600;      
                                            });                                      
                                            
                                            // Pause all playing eggs.
                                            Chicken.eggs.each(function(egg,egg_id){
                                              if( egg['status']=='at_play' )
                                                 Chicken.egg_paused($(egg_id));
                                            });
                                            
                                            // Save all eggs.
                                            Chicken.save_eggs();
                              },
  obliterate_egg : function(raw_egg){
                              var egg = null;
                              
                              if($type(raw_egg) == 'string')
                                egg = Chicken.eggs[raw_egg];
                              else
                                egg = raw_egg;
                                
                              // Destroy egg holder out.
                              if($(egg['id']))
                                $(egg['id']).destroy();
                                
                              // Destroy any edit forms out.
                              if($('edit_'+egg['id']))
                                $('edit_'+egg['id']).destroy();
                                
                              // Destroy egg.
                              Chicken.eggs.erase(egg['id']);
                              
                          }, // end function
  
  update_egg                   : function(canister){
                                            var egg = canister.retrieve('egg');
                                            var form = canister.getElement('form');
                                            
                                            // Create new egg.
                                            Chicken['create_' + egg['category']](form, canister);                                            
                                            
                                            // Delete old egg.
                                            Chicken.obliterate_egg(egg);
                                                                                      
                                        }, // end function
                      
  get_short_headline  : function(egg){
                                        // Add the short title. (This is used in the undo-delete block.)
                                        var short_headline = unescape( egg['headline'].clean() ).substr(0,50);
                                        var short_details = unescape( egg['details'].clean() ).substr(0,50);
                                        
                                        if(short_headline.length == 0 && short_details.length ==0)
                                          return 'Boring task #' + (Chicken.get_boring_task_count() );
                                        if(short_headline.length == 0)
                                          return short_details + '...';
                                        
                                        return short_headline + '...';
                                    },

                                          
  set_form_egg : function(egg, edit_form){
                              edit_form.getElement('input[name="headline"]').set('value', unescape(egg['headline']));
                              edit_form.getElement('textarea[name="details"]').set('value', unescape(egg['details']));
                              if(egg['category']=='countdown' ) {
                                edit_form.getElement('input[name="days"]').set('value',  egg['days']);
                                edit_form.getElement('input[name="hours"]').set('value',  egg['hours']);
                                edit_form.getElement('input[name="minutes"]').set('value',  egg['minutes']);
                                edit_form.getElement('input[name="seconds"]').set('value',  egg['seconds']);
                              };
                              if(egg['category']=='alarm' ) {
                                edit_form.getElement('select.hours option[value="'+(egg['hours'] % 12)+'"]').set('selected', 'selected');
                                edit_form.getElement('select.minutes option[value="'+(egg['minutes'])+'"]').set('selected', 'selected');
                                if(parseInt(egg['hours']) < 12)
                                  edit_form.getElement('select.am_pm option[value="am"]').set('selected', 'selected');
                                else
                                  edit_form.getElement('select.am_pm option[value="pm"]').set('selected', 'selected');
                              };                              
                          }, // end function

  //////////////////////////////////////////////////////////////////////////////////////////////
  
  create_countdown : function(form, ele_inject_before){
                                        var new_egg = { 
                                          'use_timer'     : true,
                                          'use_buzzer'  : true,
                                          'show_details' : false,
                                          'category'       :  'countdown',
                                          'status'           : 'at_play',
                                          'headline'        :  escape($( form.elements['headline'] ).get('value').trim()) ,
                                          'details'           :  escape($( form.elements['details'] ).get('value').trim()) ,
                                          'created_at'     : (new Date()).getTime(),
                                          
                                          'hours' : $( form.elements['hours'] ).get('value'),
                                          'minutes' : $( form.elements['minutes'] ).get('value'),
                                          'days' : parseInt( $( form.elements['days'] ).get('value')  , 10 ),
                                          'seconds' : parseInt( $( form.elements['seconds'] ).get('value') , 10)
                                        };
                                        
                                        new_egg['id'] = Chicken.get_egg_id(new_egg);
                                        
                                        // Set default headline if needed.
                                        if(new_egg['headline'].clean().length==0 && new_egg['details'].clean().length == 0 ) {
                                          new_egg['headline'] = 'Boring Task #' + (Chicken.get_boring_task_count());
                                        };                      
                                        
                                        // Set :short_headline
                                        new_egg['short_headline'] = Chicken.get_short_headline(new_egg);
                                        
                                        // Error check values user inputted.
                                        new_egg['minutes']    = (parseInt(new_egg['minutes'], 10)) ?  parseInt(new_egg['minutes'], 10) : 0 ;
                                        new_egg['hours']        = (parseInt(new_egg['hours'], 10) ) ? parseInt(new_egg['hours'], 10) : 0 ;
                                        new_egg['days']         = (new_egg['days']) ? new_egg['days'] : 0;
                                        new_egg['seconds']   = (new_egg['seconds']) ? new_egg['seconds'] : 0;
                                        
                    

                                        // Check validity.
                                        var egg_validity                 = (new_egg['days'] == 0 && new_egg['hours'] == 0 && new_egg['minutes'] == 0 && new_egg['seconds'] == 0) ? 
                                                                                        false : 
                                                                                        true;    
                                        if(!egg_validity){
                                          alert('You did not put in valid settings. Check your work.');
                                          return false;
                                        };
                                        
                                        // Calculate starting and ending times.
                                        new_egg['starts_at']  =  (new Date()).getTime();
                                        new_egg['ends_at']   = Chicken.calculate_ends_at(new_egg);
                                                        
                                        // Save eggs.
                                        if( !Chicken.save_eggs( new_egg ) )
                                          return false;
                                          
                                        // Send it to the dom.
                                        Chicken.lay_egg(new_egg, ele_inject_before);
                                        
                                        // Reset form.
                                        form.reset();
                                        form.getElements('div.time_units_block input[type=text]').each(function(ele, index){
                                          ele.value = 0 ;
                                        });
                                        form.getElement('div.headline input').set('value','');
                                        form.getElement('div.details textarea').set('value','');
                                        
                                        return new_egg;
                                      
                      }, // end function
  
  create_alarm          : function(form, ele_inject_before){
  
                                        var new_egg = { 
                                          'use_timer'     : true,
                                          'use_buzzer'  : true,
                                          'show_details' : false,
                                          'category'       :  'alarm',
                                          'status'           :  'at_play',
                                          'headline'       :  escape($( form.elements['headline'] ).get('value').trim()) ,
                                          'details'          :  escape($( form.elements['details'] ).get('value').trim()) ,
                                          
                                          'created_at'   : (new Date()).getTime(),
                                          'hours'          : $( form.elements['hours'] ).get('value'),
                                          'minutes'       : $( form.elements['minutes'] ).get('value'),
                                          'am_pm'        : $( form.elements['am_pm'] ).get('value')                            
                                        };
                                        
                                        new_egg['id']   =  Chicken.get_egg_id(new_egg);
                                        
                                        // Validate hours and minutes
                                        new_egg['hours']              = parseInt(new_egg['hours'] , 10) ;
                                        new_egg['minutes']          = (parseInt(new_egg['minutes'], 10)) ?  parseInt(new_egg['minutes'], 10) : 0 ;
                                        new_egg['hours']  = (new_egg['am_pm']=='pm') ?
                                                                          new_egg['hours'] + 12 :
                                                                          new_egg['hours'];
                                        // Set up start times and end times
                                        new_egg['starts_at'] = (new Date()).getTime()
                                        new_egg['ends_at'] = Chicken.calculate_ends_at(new_egg);
                                        
                                        // Check headline.
                                        if(new_egg['headline'].clean().length==0)
                                          new_egg['headline'] = 'Boring Task #' + (Chicken.get_boring_task_count());
                                        
                                        // Set :short_headline
                                        new_egg['short_headline'] = Chicken.get_short_headline(new_egg);
                                        
                                        // Save eggs.
                                        if( !Chicken.save_eggs( new_egg ) )
                                          return false;
                                        
                                        // Send it to the dom.
                                        Chicken.lay_egg(new_egg, ele_inject_before);                          
                            
                                        // Reset form.    
                                        form.reset();                           
                                        form.getElement('div.headline input').set('value','');
                                        form.getElement('div.details textarea').set('value','');
                                        
                                        return new_egg;
                                  }, // end function
  
  create_note            : function(form, ele_inject_before){     
                                      var new_egg = { 
                                        'category'     :  'note',
                                        'use_timer'    :   false,
                                        'show_details' : false,
                                        'status'          : 'ready_to_start',
                                        'headline'       :  escape($( form.elements['headline'] ).get('value').trim()) ,
                                        'details'          :  escape($( form.elements['details'] ).get('value').trim()),
                                        'created_at'   : (new Date()).getTime()                                       
                                      };
                                      
                                      new_egg['id']   =  Chicken.get_egg_id(new_egg);
                                        
                                      // Check validity.
                                      if( new_egg['headline'].length==0 && new_egg['details'].length == 0 ){
                                        return false;
                                      };
                                      
                                      // Set :short_headline
                                      new_egg['short_headline'] = Chicken.get_short_headline(new_egg);
                                                              
                                      // Save eggs.
                                      if( !Chicken.save_eggs( new_egg ) )
                                        return false;
                      
                                      // Send it to the dom.
                                      Chicken.lay_egg(new_egg, ele_inject_before);                        
                                      
                                      // Reset form.
                                      form.reset();
                                      
                                      return new_egg;
                                  }, // end function
                                                                                  
  ///////////////////////////////////////////////////////////////////////////////////////////////
                                        
  egg_states : $A([
                        'ready_to_start',
                        'at_play',
                        'paused',
                        'times_up',
                        'x_marked',
                        'check_marked',
                        'edit',
                        'deleted'
                        ]),
  egg_ringer_option_changed    : function(checkbox){
                                                    var egg_div = checkbox.getParent('div.buzzer_option');
                                                    var egg       = checkbox.getParent('div.egg').retrieve('egg');
                                                    egg['use_buzzer'] = checkbox.checked;
                                                    
                                                    if(checkbox.checked){
                                                      egg_div.addClass('selected_buzzer');
                                                    } else {
                                                      egg_div.removeClass('selected_buzzer');
                                                    };
                                                    
                                                    return checkbox.checked;
                                                }, // end function
                                                
  egg_ready_to_start       : function(canister){
                                            var egg = canister.retrieve('egg');
                                            egg['status'] = 'ready_to_start';
                                                                                      
                                            // Update canister.
                                            $(egg['id']).removeClasses(Chicken.egg_states);
                                            $(egg['id']).addClass(egg['status']);  
                                            
                                          // save eggs.
                                          Chicken.save_eggs();
                                          
                                          return egg;
                                         },
                                         
  egg_at_play                  : function(canister){
                                            var egg = canister.retrieve('egg');
                                            
                                            // Update start/end time.
                                            if(egg['status'] != 'paused' ){
                                              
                                              egg['starts_at'] = (  (new Date()).getTime()   ) ;
                                              egg['ends_at']  = Chicken.calculate_ends_at(egg);
                                                        
                                            } else { // the egg is coming out of being paused.
                                              egg['ends_at']     = (new Date()).getTime() + (egg['ends_at'] - egg['starts_at'] ); 
                                              egg['starts_at']   = (new Date()).getTime();
                                            };               
                                            
                                            // Update egg.                       
                                            egg['status'] = 'at_play';
                                            egg['ignore_buzzer'] = false;
                                            
                                            // Update egg holder.
                                            canister.removeClasses(Chicken.egg_states);
                                            canister.addClass(egg['status']);  
                                            var diff_units = EggClock.get_difference_in_units( egg['starts_at'], egg['ends_at']);
                                            canister.getElement('div.time_status').set( 'html', Chicken.format_time_status( diff_units ) );
                                            
                                            // save eggs.
                                            Chicken.save_eggs();
                                            
                                            return egg;
                                            
                                         }, // end function
                                         
  egg_unclean_paused    : function(canister){
                                          var egg = canister.retrieve('egg');
                                          if(egg['category'] != 'countdown')
                                            return false;
                                            
                                          // Check if it is newly formed.
                                          if( (new Date()).getTime() - egg['created_at']  < 5000 )
                                            return false;
                                          
                                          if(egg['status'] != 'at_play')
                                            return false;
                                          
                                          egg['ends_at'] += 600; // compenstate for the fact that timeout still runs when page is not rendering during reload or shutdown.                                          
                                          
                                          Chicken.egg_paused($(egg['id']));
                                          
                                          return egg;
                                          }, // end function         
                                             
  egg_paused                  : function(canister){
                                            var egg = canister.retrieve('egg');
                                            // Update egg.
                                            if(egg['category'] != 'countdown')
                                              return false;
                                                                                          
                                            egg['status'] = 'paused';                                  
                                            
                                            // Update canister
                                            canister.removeClasses(Chicken.egg_states);
                                            canister.addClass(egg['status']);    
                                            canister.getElement('div.time_status_in_words').set( 'html',  '(Paused)' );
                                            
                                            // save eggs.
                                            Chicken.save_eggs();                                            
                                            
                                            return egg;
                                         }, // end function
                                         
  egg_times_up               : function(canister){
                                            
                                            var egg = canister.retrieve('egg');
                                            egg['status'] = 'times_up';
                                            
                                            canister.removeClasses(Chicken.egg_states);
                                            canister.addClass(egg['status']);    
                                            
                                            var diff_units = EggClock.get_difference_in_units( egg['starts_at'], egg['ends_at']);
                                            canister.getElement('div.time_status').set( 'html',  Chicken.format_time_status( diff_units ) ); 
                                            
                                            if(egg['use_buzzer'] && !egg['ignore_buzzer'])
                                              EggClock.start_buzzer(egg['id']);                                            
                                              
                                            // save eggs.
                                            Chicken.save_eggs();     
                                            
                                            return egg;                                       
                                          }, // end function
                                          
  egg_x_marked              : function(canister){
                                            var egg = canister.retrieve('egg');
                                            egg['status'] = 'x_marked';
                                            canister.removeClasses(Chicken.egg_states);
                                            canister.addClass(egg['status']);   
                                            
                                            EggClock.stop_buzzer(egg['id']);              
                                            
                                            // save eggs.
                                            Chicken.save_eggs();   
                                            return egg;                                                                        
                                          }, // end function
                                          
  egg_check_marked       : function(canister){
                                            var egg = canister.retrieve('egg');
                                            egg['status'] = 'check_marked';
                                            canister.removeClasses(Chicken.egg_states);
                                            canister.addClass(egg['status']);    
                                            
                                            EggClock.stop_buzzer(egg['id']);      
                                                                                  
                                            // save eggs.
                                            Chicken.save_eggs();        
                                            return egg;                                    
                                          },
                                          
  egg_edit                        : function(canister){
                                            var egg = canister.retrieve('egg');
                                            
                                            // Set record to starting position.
                                            Chicken.egg_ready_to_start(canister);
                                            canister.removeClasses(Chicken.egg_states);
                                            canister.addClass('edit');   
                                            
                                            // Create edit form.
                                            var edit_div = $first('#dom_templates div.create_' + egg['category']).clone();
                                            edit_div.set('id', 'edit_' + egg['id']);
                                            // Send it to the DOM so all Element methods work properly.
                                            edit_div.inject(canister, 'before');     
                                            
                                            // Store egg to edit canister.
                                            edit_div.store('egg', egg);                                       
                                            
                                            // Update values in form.
                                            Chicken.set_form_egg(egg, edit_div.getElement('form') );
                                            // Set up short title
                                            edit_div.getElement('span.short_headline').set('html', egg['short_headline'])
                                            
                                            // Add actions to  form.
                                            edit_div.getElements('form').each(function(frm){ frm.onsubmit = function(){return false;}; });
                                            edit_div.getElement('button.save').onclick = function(){
                                                                                                                    var canister = $(this).getParent('div.edit_egg');
                                                                                                                    Chicken.update_egg(canister);
                                                                                                                    return false;
                                                                                                                  };
                                            edit_div.getElement('button.cancel').onclick = function(){
                                                                                                                      var canister = $(this).getParent('div.edit_egg');
                                                                                                                      Chicken.egg_cancel_edit(canister);
                                                                                                                      return false;
                                                                                                                  };                                                                                                                  
                                            edit_div.getElement('button.delete').onclick = function(){
                                                                                                                      var canister = $(this).getParent('div.edit_egg');
                                                                                                                      Chicken.egg_delete(canister);
                                                                                                                      return false;
                                                                                                                  };  
                                                                                                                  
                                            // Store egg to form.
                                            edit_div.store('egg', egg);
                                            
                                            return egg;                                           
                                          }, // end function
   
  egg_cancel_edit             : function(edit_canister){
                                            var canister = $(edit_canister.retrieve('egg')['id']);
                                            edit_canister.destroy();
                                            return Chicken.egg_ready_to_start(canister);
                                         }, // end function
                                        
  egg_delete                      : function(edit_canister){
                                          
                                          var canister = $(edit_canister.retrieve('egg')['id']);
                                          
                                          // Destroy edit form.
                                          edit_canister.destroy();
                                          
                                          // Set egg to starting position.
                                          Chicken.egg_ready_to_start(canister);
                                          
                                          // Update egg.
                                          var egg = canister.retrieve('egg');
                                          egg['status'] = 'deleted';
                                          
                                          // Update egg holder.
                                          canister.removeClasses(Chicken.egg_states);
                                          canister.addClass(egg['status']);    
                                            
                                          // save eggs.
                                          Chicken.save_eggs();     
                                                  
                                          return null;                               
                                        }, // end function 
                                              
  egg_undelete              : function(canister){
                                          return Chicken.egg_ready_to_start(canister);                                                                               
                                      },
                                      
  egg_show_details : function(canister){
                                  var egg = canister.retrieve('egg');
                                  egg['show_details'] = true;
                                  // Update canister.
                                  canister.removeClass('hide_details');
                                  canister.addClass('show_details');
                                },
  
  egg_hide_details : function(canister){
                                  var egg = canister.retrieve('egg');
                                  egg['show_details'] = false;
                                  
                                  // Update canister.
                                  canister.removeClass('show_details');
                                  canister.addClass('hide_details');
                                }                                                         
  ///////////////////////////////////////////////////////////////////////////////////////////////

}; // end Chicken



 var egg_template = {
    id                  : 'String',
    created_at    : 'UNIX epoch time',
    starts_at      : 'UNIX epoch time',
    ends_at         : 'UNIX epoch time',   
    show_details : 'Boolean', 
    use_timer     : 'Boolean', // Set to false for Notes and any other category
    use_buzzer  : 'Boolean',
    status           : 'String',
    ignore_buzzer : 'Boolean',         // ****************************************************************************
                                                   // Sometimes people close the browser while egg is beeping. This makes sure than 
                                                   //  when egg is laid down from a previous session, it does not re-beep upon
                                                   //  a new session.
                                                   // ****************************************************************************
    category : 'String',
    short_headline : 'String', // This is used in the undo-delete block.
    headline    : 'String',
    details       : 'String',
    
    hours : 'Int',
    minutes : 'Int',
    days: 'Int',
    seconds: 'Int'
}    








