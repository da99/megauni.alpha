/*

*  Window Onload:
*   - Start clock.
*   - Load events into memory.
*   - Draw events onto the screen.
*   - Activate each events based on last 
*      state if it's been less than 24 hours.

*/



// When page is first loaded...
var egg_storage = false;
var eggs = $A([]);  // All the saved and newly created tasks go here.


/* start importing eggs */

/* end importing eggs */



var allowed_storage_types = $A(['globalstorage', 'localstorage', 'whatwg_db', 'ie']);
var advanced_browser = window.ie || window.gecko || window.webkit;



window.addEvent('load', function(){
	// Hide any certain features from certain browsers.
	if(!advanced_browser) {
		$('create_note').setStyle('display' , 'none');
	};
	egg_clock.start();
	
	// Re-write email to a more user friendly format.
	var new_email = '';
	$ES('#intro span.email, #tips span.email').each(function(email_span){
		if(email_span.innerHTML) {
			new_email = email_span.innerHTML.replace(' [at] ', '@').replace(' [dot] ', '.');
			email_span.setHTML(  '<a href="mailto:'+new_email+'" title="Send me bug reports, Beautiful Stranger.">'+new_email+'</a>' );
		};
	});

	// Retrieve saved eggs (tasks).
	egg_storage = new Persist.Store('myEggTimer');

	// Hide full features list for certain browsers.
	if( allowed_storage_types.contains(Persist.type) )
		if($E('#intro div.full_features'))
			$E('#intro div.full_features').setStyle('display', 'block');
	// Make sure to do DOM manipulation within the callback function given to egg_storage.get.

	// This has something to do with asynchronsity and PersistJS.

	if( allowed_storage_types.contains(Persist.type) )

		egg_storage.get('eggs',function(ok, val){ 

			if(ok && val && eggs.length==0){

				switch($type(val)){

					case 'string':

						eggs = $A(Json.evaluate(val, true));

						break;

					case 'object':

						if(val.value)

							eggs = $A(Json.evaluate(val.value, true));

						break;

						

				};

				

				// lay down saved eggs.

				Chicken.lay_all_eggs();

				

			};

			

		});

							

	$('all_my_stuff').setStyle('visibility', 'visible');

        $('minimize_add_stuff').onclick = function(){

            $('add_stuff').addClass('minimized');

            return false;

        };

        $('expand_add_stuff').onclick = function(){

            $('add_stuff').removeClass('minimized');

            return false;

        };

});



// When user leaves... "bye bye user"... clean up first.

window.addEvent('unload', function(){

 egg_clock.end();
 
 // Check to see if this is not Safari.
 // Safari does not give you access to the datastore during unload events.  Could be a bug in the browser.
 if( window.advanced_browser && !window.webkit) {
	Chicken.save_eggs();
 };

});







Element.extend({

	getAncestor: function(tagName){

		

		if( !this.parentNode )

			return null;

		var ancestor = this.parentNode;

		while(ancestor && ancestor.tagName != tagName)

			ancestor = ancestor.parentNode;

			

		return( $(ancestor) );

	},

	removeClasses : function(){

		var this_element = this;

		$A(arguments).each(function(arg){

			if($type(arg) == 'array')

				$A(arg).each(function(classname){ this_element.removeClass(classname) });

			else

				this_element.removeClass(arg);

		});



	}

});



String.extend({

	nl2br : function(){ // from: http://snipplr.com/view/634/replace-newlines-with-br-platform-safe/

				

				if(this.trim().length==0)

					return this;

					

				var text = escape(this);

				var re_nlchar = false;

				

				if(text.indexOf('%0D%0A') > -1){

					re_nlchar = /%0D%0A/g ;

				}else if(text.indexOf('%0A') > -1){

					re_nlchar = /%0A/g ;

				}else if(text.indexOf('%0D') > -1){

					re_nlchar = /%0D/g ;

				};

				

				if(!re_nlchar)

					return this;

					

				return( unescape( text.replace(re_nlchar,'<br />') ) );

			}

});



var Chicken = {

	

	egg_states : $A(['at_peace', 'playing', 'paused', 'times_up', 'done']),

	

	egg_states_in_words : {'at_peace' : '' , 'playing' : '' , 'paused': '(Paused.)', 'times_up' : '---', 'done': 'Done, done, and done.'},

	

	// egg_buttons_and_actions : , // end egg_buttons_and_actions

	

	storage_bin : {

		'highlight_start' : '#073D6F',

		'highlight_end'   : '#FFFF99'

	},

	get_egg_id : function(egg){

		if(egg.created_at)

			return( 'task_' + (new Date(parseInt(egg.created_at))).getTime() + '' + eggs.length );

		else 

			return( 'task_' + (new Date()).getTime() + '' + eggs.length );

	},

	show_egg_list : function(){ $('my_work').setStyle('display', 'block'); },

	hide_egg_list : function(){ $('my_work').setStyle('display', 'none'); },

	highlight : function(){

		

		var ele = $(arguments[0]) || $E(arguments[0]);

		var start_color 	= ( arguments[1] ) ? arguments[1] : this.storage_bin.highlight_start;

		var end_color 		= ( arguments[2] ) ? arguments[2] : this.storage_bin.highlight_end;

		var css_property    = (arguments[3]) ? arguments[3] : 'background-color';

		var effect_length   = (arguments[4]) ? arguments[4] : 800;

		var store_index 	= (ele.id || arguments[0] ) +' higlight ' + css_property ;

		

		// Cache effect.

		if(!this.storage_bin[store_index])

			this.storage_bin[store_index] = new Fx.Style( ele, css_property, {duration: effect_length});

		

		// Make sure element is visible.

		ele.setStyle('display', 'block');

		ele.setStyle('visibility', 'visible');

		

		// Highlight.

		this.storage_bin[store_index].start( start_color, end_color);

	}, // end fx

	

	lay_all_eggs : function() {
	
		var current_get_time = (new Date()).getTime();
		
		eggs.each(function(egg,index){
		   egg['id'] = Chicken.get_egg_id(egg);
		   egg['id_suffix'] = parseInt(egg['id'].replace('task_',''));
		   
		   // ****************************************************************************
		   // Sometimes people close the browser while egg is beeping. This makes sure than 
		   //  when egg is laid down from a previous session, it does not re-beep upon
		   //  a new session.
		   // ****************************************************************************
		   var alarm_has_ended = ( egg['egg_type'] == 'alarm' && egg['ends_at'] && egg['ends_at'] < current_get_time ) &&
									(egg['status'] == 'playing' || egg['status'] == 'times_up');
		   var countdown_is_times_up  = ( egg['egg_type'] == 'countdown' && egg['status'] == 'times_up' );
		   if( alarm_has_ended || countdown_is_times_up ) 
			egg['ignore_buzzer'] = true; 
		   // ****************************************************************************
		   
		   if( egg['status'] != 'deleted' )
			Chicken.lay_egg(egg);
		   
		});
	}, // end lay_all_eggs
	
	/* Returns: reference to egg.
	*/
	lay_egg   : function(egg_hash){ 

					

					// Clong egg canister.

					var new_egg = $$('#dom_templates div.egg_template_'+egg_hash['egg_type'])[0].clone();

					

					// Re-name new canister.

					new_egg.setAttribute('id', egg_hash['id'] );

					

					// Send new canister to the DOM.

					new_egg.injectTop( $('my_tasks') );

					

					// Update text in canister.

					$E('#'+egg_hash['id']+' h4').setHTML( unescape(egg_hash['title_and_details']).nl2br() );

					

					// Add actions to BUTTONs in egg's DIV block.

					this.add_button_actions_to_egg( egg_hash );

					// Add the short title. (This is used in the undo-delete block.)
					var short_title = unescape( egg_hash['title_and_details'] ).substr(0,50);
					
					if(short_title != egg_hash['title_and_details'])
						short_title = short_title + '...';
					else
						short_title = short_title;
					
					if( $E('#'+egg_hash['id']+' span.short_title') )
						$E('#'+egg_hash['id']+' span.short_title').setHTML( short_title );

					// *******************************************************************
						
					if(egg_hash['timed']) {

						// Update text in canister.

						$E('#'+egg_hash['id']+' div.setting').setHTML( Chicken.format_setting(egg_hash) );

						$E('#'+egg_hash['id']+' div.time_status_in_words').setHTML( Chicken.egg_states_in_words[egg_hash['status']] );
						

					

						// Update buzzer option.

						$E('#'+egg_hash['id']+' div.buzzer_option input').checked = egg_hash['use_buzzer'];

						if(!egg_hash['use_buzzer'])

							$E('#'+egg_hash['id']+' div.buzzer_option').removeClass('buzzer_selected');

						

						// Pause this egg if it was previously playing and if it's a countdown..

						if( !egg_hash['newly_formed'] && 

								egg_hash['egg_type'] == 'countdown' && 

									egg_hash['status'] == 'playing' ){

							Chicken.update_egg_status(egg_hash, 'unclean_paused' );

							

						};

						

						// Update time status if it is paused.

						if(egg_hash['status'] == 'paused')

							$E('#'+egg_hash['id']+' div.time_status').setHTML( Chicken.format_time_status(egg_hash) );

						

					}; // end if: egg is timed

					

					// Update canister.

					if(egg_hash['timed'] && egg_hash['newly_formed']) {

						$E('#' + egg_hash['id'] + ' div.time_status').setHTML( '<span class="number">* * * *</span>' );

						Chicken.update_egg_status(egg_hash , 'playing');

					} else // just update the canister if it is not newly formed.
						Chicken.update_canister(egg_hash);
										
					// Make work collection visible just in case.
					Chicken.show_egg_list();
					
					// Hide the intro since it is not necessary anymore.
					$('intro').setStyle('display', 'none');
					
					// set laid_at timestamp
					egg_hash['laid_at']= (new Date()).getTime();

				},

	

	form_egg : function(form){

					var new_egg = { 

						'title_and_details' :  escape($( form.elements['title_and_details'] ).getValue().trim()) ,

						'egg_type' : $( form.elements['egg_type'] ).getValue(),

						'newly_formed' : true

					};

					new_egg['id'] = this.get_egg_id(new_egg);

					new_egg['id_suffix'] = parseInt(new_egg['id'].replace('task_',''));

					

					// Do special handling depending on egg type.

					switch(new_egg['egg_type']){

						case 'countdown':

							new_egg['status'] = 'playing';

							new_egg['time_status_in_words'] = 'Playing';

							new_egg['hours'] = $( form.elements['hours'] ).getValue();

							new_egg['minutes'] = $( form.elements['minutes'] ).getValue();

							new_egg['use_buzzer'] = true; 

							new_egg['timed'] = true;

							

							new_egg['days']    = parseInt( $( form.elements['days'] ).getValue()  , 10 );

							new_egg['seconds'] = parseInt( $( form.elements['seconds'] ).getValue() , 10);

							

							// Error check values user inputted.

							new_egg['minutes'] = (parseInt(new_egg['minutes'], 10)) ?  parseInt(new_egg['minutes'], 10) : 0 ;

							new_egg['hours'] 	= (parseInt(new_egg['hours'], 10) ) ? parseInt(new_egg['hours'], 10) : 0 ;

							new_egg['days'] 	= (new_egg['days']) ? new_egg['days'] : 0;

							new_egg['seconds'] 	= (new_egg['seconds']) ? new_egg['seconds'] : 0;

							

							// Check title.

							if(new_egg['title_and_details'].length==0)

								new_egg['title_and_details'] = 'Nameless Boring Task #' + (eggs.length+1);



							

							new_egg['valid'] = (new_egg['days'] == 0 && new_egg['hours'] == 0 && new_egg['minutes'] == 0 && new_egg['seconds'] == 0) ? false : true;  

							

							break;

						case 'alarm':

							new_egg['status'] = 'playing';

							new_egg['time_status_in_words'] = 'Playing';

							new_egg['hours'] = $( form.elements['hours'] ).getValue();

							new_egg['minutes'] = $( form.elements['minutes'] ).getValue();

							new_egg['use_buzzer'] = true;

							new_egg['timed'] = true;

							

							new_egg['minutes'] = (parseInt(new_egg['minutes'], 10)) ?  parseInt(new_egg['minutes'], 10) : 0 ;

							new_egg['am_pm'] = $( form.elements['am_pm'] ).getValue();

							new_egg['hours'] 	= parseInt(new_egg['hours'] , 10) ;

							

							// Check title.

							if(new_egg['title_and_details'].trim().length==0)

								new_egg['title_and_details'] = 'Nameless Boring Task #' + eggs.length;

							

							if(new_egg['am_pm']=='pm')

								new_egg['hours'] += 12;

							

							new_egg['valid']	= true; // valid by default.

							

							break;

						case 'note':

							new_egg['status'] = 'at_peace';

							new_egg['timed'] = false;

							new_egg['valid'] = new_egg['title_and_details'].length != 0;

							break;

					}; // end switch

					

					

					// Check validity of eggs.

					if(new_egg['timed'] && !new_egg['valid']) { 

						alert('The values you entered for the '+new_egg['egg_type']+' don\'t make sense :( Please re-check for any typos.');

						return false;

					} else if(!new_egg['valid']) { // Don't show error message if this is a note. Notes/to-dos are too simple to justify an error message.

						return false;

					};
						
					// Add it to the rookery.
					eggs.include( new_egg );
					
					// Save eggs.
					egg_storage.set('eggs', Json.toString(eggs) );
					
					// Send it to the dom.
					Chicken.lay_egg(new_egg);
					
					return new_egg;
				}, // end form_egg


	format_time_status : function( egg_or_time_unit_hash ){ // time_unit_hash is based on egg_clock.get_difference_in_units

		var time_unit_hash = ( egg_or_time_unit_hash['egg_type'] ) 

								? egg_clock.get_difference_in_units(egg_or_time_unit_hash['started_at'], egg_or_time_unit_hash['ends_at']) 

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

		switch(egg_hash['egg_type']){

			case 'alarm':

				return egg_clock.format_12hour(egg_hash['hours']) + 

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

	},

	

	calculate_end_time_from_now : function(egg_hash) {

		if( !egg_hash['valid'] )

			return 0;

		var right_now = new Date();

		var right_now_without_milliseconds = new Date( Date.parse( right_now.toLocaleString() ) );

		

		if( egg_hash['egg_type'] == 'countdown' ) {

			var time_in_milli_seconds = ( (egg_hash['days'] * 24 * 60 * 60) + (egg_hash['hours'] * 60 * 60) + (egg_hash['minutes'] * 60) + egg_hash['seconds'] ) * 1000;

			return(right_now.getTime() + time_in_milli_seconds);

		}; // end countdown

		

		if( egg_hash['egg_type'] == 'alarm' ) {
      var target = new Date();
      
      target.setHours( egg_hash['hours'] );
      target.setMinutes( egg_hash['minutes'] );
      target.setSeconds(0);
      
      var target_time = target.getTime();
      
      if(target.getTime() < right_now.getTime() ){
        target_time += (24 * 60 * 60 * 1000);
      };
      
      return( target_time );
      

		}; // end alarm

		

	}, // end calculate_end_time_from_now

	

	sees_if_any_hatched : function(){

		// Go through each egg to see which ones are :playing or :paused.
		// Update the DOM when neccessary.
		eggs.each(function(egg, index){
			switch(egg['status']){
				
				case 'paused':
					break;
					
				case 'playing':
					
					var diff_units = egg_clock.get_difference_in_units( egg['started_at'], egg['ends_at']);
					
					if(diff_units['invalid']){
						Chicken.update_egg_status(egg, 'at_peace');
					};
					
					if(diff_units['times_up']){ // this egg has hatched!  Quick, tell the farmer!
						Chicken.update_egg_status(egg, 'times_up');
					} else { // move egg closing to hatching.
						// bring it closer to :ends_at
						egg['started_at'] = (new Date()).getTime(); 
						if($(egg['id']))
							$E('#' + egg['id'] + ' div.time_status').setHTML( Chicken.format_time_status( diff_units ) );
					};
					
					egg['newly_formed'] = false; // make sure this does not start up next time automatically.
					
					// Safari does not give you access to the datastore during unload events so save them
					//  every 5 seconds.
					if( window.webkit && ((new Date()).getSeconds() % 5) == 0 ) 
						Chicken.save_eggs();
					break;
					
			};

		});

	},

	

	pause_all_playing_eggs : function(){



		eggs.each(function(egg,index){

			if(egg['timed'] && egg['status']=='playing' )

				 Chicken.update_egg_status(egg, 'paused');

		});

	}, // end pause_all_playing_eggs

	update_egg_status : function( egg, status ) {
		switch(status){
			case 'playing':
				
				var right_now_without_milliseconds = new Date( Date.parse( (new Date()).toLocaleString() ) );
				
				if(egg['status'] != 'paused' ){
					
					egg['started_at'] = (  (new Date()).getTime()    ) ;
					egg['ends_at']  = Chicken.calculate_end_time_from_now(egg);
										
				} else { // the egg is coming out of being paused.
					egg['ends_at'] 		= (new Date()).getTime() + (egg['ends_at'] - egg['started_at'] ); 
					egg['started_at'] 	= (new Date()).getTime();
				};
				egg['status'] = status;
				
				break;
			
			case 'unclean_paused':
				if(egg['egg_type'] != 'countdown')
					return false;
				
				egg['status'] = 'paused';
				egg['ends_at'] += 600; // compenstate for the fact that timeout still runs when page is not rendering during reload or shutdown.
				break;
			case 'paused':
				if(egg['egg_type'] != 'countdown')
					return false;
				
				egg['started_at'] = (new Date()).getTime()  ;
				egg['status'] = status;
				break;
			
			case 'times_up':
			case 'done':
				egg['status'] = status;
				break;
			
			
			case 'at_peace': 
				egg['status'] = status;
				
				// use this update to reset other values like 'ignore_buzzer'
				egg['ignore_buzzer'] = false;
				
				break;
			case 'deleted':
				$(egg['id']).addClass('deleted');
				egg['old_status'] = egg['status'];
				egg['status'] = 'deleted';
				
				// if(eggs.length == 0 ) {
				// 	$('intro').setStyle('display', 'block');
				//	Chicken.hide_egg_list();
				// };
				break;
				
			case 'undeleted':
				$(egg['id']).removeClass('deleted');
				egg['status'] = egg['old_status'];
				break;
		};
		
		// save eggs.
		this.save_eggs();
		
		// Update canister.
		this.update_canister(egg);
		
	}, // end update_egg_status



	save_eggs : function(){

		  if(allowed_storage_types.contains(Persist.type)) {

			egg_storage.set( 'eggs', Json.toString(eggs) );

		  };

	}, // end save_eggs

	

	update_canister : function(egg){ // update the DOM and DIV that holds  the egg based on it's status.

		

		// For MSIE. If the page is unloading, document won't has access to certain methods and properties.
		//  Function '$' would then cause an error.
		if(!document.getElementById) 
			return false;
		
		var canister = $(egg['id']);
		
		if(!canister)
			return false;
		
		canister.removeClasses(Chicken.egg_states);
		canister.addClass(egg['status']);
		
		switch(egg['status']){
			
			case 'times_up':
				var diff_units = egg_clock.get_difference_in_units( egg['started_at'], egg['ends_at']);

				$$('#' + egg['id'] + ' div.time_status')[0].setHTML( Chicken.format_time_status( diff_units ) ); 

				if(egg['use_buzzer'] && !egg['ignore_buzzer'])
					egg_clock.start_buzzer(egg['id']);
				
				break;
			case 'playing': 

				var diff_units = egg_clock.get_difference_in_units( egg['started_at'], egg['ends_at']);

				$$('#' + egg['id'] + ' div.time_status')[0].setHTML( Chicken.format_time_status( diff_units ) );

				break;

			case 'at_peace':

				break;

			case 'paused':

				$$('#' + egg['id'] + ' div.time_status_in_words')[0].setHTML( '(Paused)' );

				break;

			case 'done':

				$$('#' + egg['id'] + ' div.time_status_in_words')[0].setHTML( 'Done.' );

				egg_clock.stop_buzzer(egg['id']);

				break;

		}; // end switch

	}, // end update_canister

	

	add_button_actions_to_page : function(){ // called when page has finished loading.

		

		// Stop create forms from being submitted.

		$$('form.create_egg').each(function(form){

			form.onsubmit = function(){return false};

		});
		
		
		// Add actions to create_note. ***************************************************************
		$E('#form_note button.start').onclick = function(){

				if( !Chicken.form_egg( $('form_note') ) )

					return false;

					

				$('form_note').reset();

				$('form_note').addClass('submitted');

				Chicken.highlight( '#form_note div.submitted_msg' );

				return false;

			};

		$E('#create_note a.expose').onclick 	= function(){ $E('#create_note div.land').addClass('exposed'); return false};

		$E('#create_note a.cover_up').onclick 	= function(){ $E('#create_note div.land').removeClass('exposed'); return false};

		

		// Add actions to create_countdown. ***********************************************************

		$E('#form_countdown button.start').onclick=function(){ 

				if( !Chicken.form_egg( $('form_countdown') ) ) 

					return false;

				

				$('form_countdown').addClass('submitted');

				Chicken.highlight( '#form_countdown div.submitted_msg' );

				$$('#form_countdown input[type=text]', '#form_countdown textarea').each(function(ele, index){
					ele.value = (ele.tagName=='INPUT') ? 0 : '';
				});
				
				// Reset form.
				$('form_countdown').reset();
				
				return false;

			};

			

		// Add actions to create_alarm. ***************************************************************

		$E('#form_alarm button.start').onclick = function(){ 

				if(!Chicken.form_egg( $('form_alarm') ))
					return false;
				$('form_alarm').addClass('submitted');
				Chicken.highlight('#form_alarm div.submitted_msg');
				
				$$('#form_alarm textarea')[0].value ='';
				
				// Reset form.
				$('form_alarm').reset();
				
				return false;

			};
		
		// Make submitted message go away when egg creation forms are re-used. ****************************
		$$('#add_stuff input[type=text]', '#add_stuff textarea').each(function(ele, index){
			ele.addEvent('click', function(){
				$E('div.submitted_msg', this.getAncestor('FORM') ).setStyle('display','none');
			});
		});

	},

	add_button_actions_to_egg : function(egg){

		var egg_div = $(egg['id']);
		
		if(!egg_div)
			return false;
		

		if(!this.storage_bin.egg_buttons_and_actions) {

			this.storage_bin.egg_buttons_and_actions = new Hash({

													'pause' 		: 'paused', 

													'play' 			: 'playing', 

													'mark_as_done' 	: 'done', 

													'reset' 		: 'at_peace',

													'edit'          : 'deleted',
													
													'undo'			: 'undeleted'

												});

		};

		

		//  Loop through the buttons and add the corresponding action.

		this.storage_bin.egg_buttons_and_actions.each(

			function(status, button_class){

				egg_div.getElements('a.'+button_class).each(function(link_button){

					link_button.onclick = function(){ 

						Chicken.update_egg_status(egg, status); 

						return false;

					};

				});

			}

		); 

		

		if(egg['timed'])

			egg_div.getElements('div.buzzer_option input')[0].addEvent('click', function(){

				if(this.checked){

					egg_div.getElements('div.buzzer_option')[0].addClass('buzzer_selected');

					egg['use_buzzer'] = true;

					

				} else {

					egg_div.getElements('div.buzzer_option')[0].removeClass('buzzer_selected');

					egg['use_buzzer'] = false;

				};
			});
		

	} //  end add_button_actions_to_egg

	

}; // end Chicken







var egg_clock = {



	month_names : ['Jan.', 'Feb.', 'Mar.', 'April', 'May', 'June', 'July', 'Aug.', 'Sept.', 'Oct.', 'Nov.', 'Dec.'],

	day_names     : ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],

	storage_bin : $A({}),
	
	clock_is_running : false,
	clock_js_id : 0,
	start : function(){

	  this.clock_js_id = setInterval( egg_clock.next_second, 1000 );

	},

  

	end   : function(){ clearInterval( egg_clock.clock_js_id ); },





	format_month_name : function(date){ return( this.month_names[date.getMonth()] ); },

	format_day        : function(date){ return( this.day_names[date.getDay()  ] ); },

	format_minutes    : function(date){ return( (date.getMinutes()<10) ? '0'+date.getMinutes() : date.getMinutes() );},

	format_meridian   : function(date){ return( (date.getHours()>12) ? 'P.M.' : 'A.M.'  ); },



	format_12hour : function( date_or_hour ){ 

					var orig_hour = ( (date_or_hour).getHours ) 

										? date_or_hour.getHours() 

										: parseInt(date_or_hour);

					var hour = ( orig_hour < 1 ) 

								? 12 

								:  ( (orig_hour < 13) ? orig_hour : orig_hour % 12 );

					return hour;

	},



	format_year : function( date ){ /* based on function: takeYear from:  http://www.quirksmode.org/js/introdate.html#year */

					var y = date.getYear() % 100;

					return( y + ( (y < 38) ? 2000 : 1900 ) ); 

	},

	

	chop_off_milliseconds : function(orig_epoch_time){

		return( parseInt(orig_epoch_time / 1000) * 1000 );

	}, // 

  

  next_second : function(){

    var right_now = new Date();
	
	$('big_seconds').setHTML( ', ' + right_now.getSeconds() + ' sec.' );

	// Update hour...

	if( !egg_clock.clock_is_running || right_now.getSeconds() < 1 )

	  $('big_hour').setHTML( egg_clock.format_12hour(right_now) + ':' + egg_clock.format_minutes(right_now) + ' ' + egg_clock.format_meridian(right_now)  );
	
	// Update date...

	if( !egg_clock.clock_is_running || (right_now.getHours() < 1 && right_now.getMinutes() < 1 && right_now.getSeconds() < 1 ) )

	  $('big_date').setHTML(  egg_clock.format_day(right_now) + ' - ' + egg_clock.format_month_name(right_now) + ' ' + right_now.getDate() + ', ' + egg_clock.format_year(right_now)  );
	  
	// Show main elements...
	if( !egg_clock.clock_is_running ) {
		$('add_stuff').setStyle('display', 'block');
		Chicken.add_button_actions_to_page();
	};
	
	// Make sure next time this function is called, it knows it is not the
	//  first time.
	egg_clock.clock_is_running = true;
	
	// Update eggs (tasks).
	Chicken.sees_if_any_hatched();
	
  }, // end next_second

  

  epoch_units : { 'days' : (24 * 60 * 60 * 1000), 'hours' : (60 * 60 * 1000), 'minutes' : (60 * 1000), 'seconds' : 1000},

  

  get_difference_in_units : function(beginning_epoch, ending_epoch) {

	var units = { 'days' : 0, 'hours' : 0 , 'minutes' : 0, 'seconds' : 0 , 't_sign' : '-', 'times_up' : false};

	

	var earliest 		= ( beginning_epoch < ending_epoch ) ? beginning_epoch : ending_epoch;

	var latest   		= ( beginning_epoch < ending_epoch ) ? ending_epoch : beginning_epoch;

	units['t_sign']	  	= ( beginning_epoch <= ending_epoch ) ? '-' : '';

	units['times_up'] 	= ( ending_epoch <= beginning_epoch );

	

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
		units['seconds'] = parseInt( difference / this.epoch_units['seconds'] );

	

	units['invalid'] = !( $chk(units['days']) && $chk(units['hours']) && $chk(units['minutes']) && $chk(units['seconds']) );

	return units;

  },

  start_buzzer : function(event_id){

				this.storage_bin.include(event_id);

				// add alarm to DOM.

				if($('egg_clock_alarm'))

					return false;

				

				var player_html = '';

				var url_prefix = '/my-egg-timer';

				if(window.ie) {

					player_html = '* *<bgsound loop="25" SRC="http://megauni.s3.amazonaws.com/beeping.wav" />';

				} else {

				  player_html += '    <p>*';

				  player_html += '      <object  type="application/x-shockwave-flash" data="'+url_prefix+'/javascripts/button_player/button/musicplayer_f6.swf?&autoplay=true&repeat=true&song_url=http://megauni.s3.amazonaws.com/beeping.mp3&"  width="2"  height="2" >';

				  player_html += '       <param name="movie"  value="'+url_prefix+'/javascripts/button_player/button/musicplayer_f6.swf?&autoplay=true&repeat=true&song_url=http://megauni.s3.amazonaws.com/beeping.mp3&" />';

				  player_html += '       <img src="'+url_prefix+'/images/loading.gif" width="43" height="1" alt="*" />';

				  player_html += '      </object>';

				  player_html += '    </p>';

				};

				

				$('alarm_holder').setHTML(player_html);

  },

  stop_buzzer : function(event_id){

	this.storage_bin.remove(event_id);

	if(this.storage_bin.length < 1)

		$('alarm_holder').setHTML('');

  }

}; // end egg_clock
