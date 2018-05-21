/*
 * ========== HOW TO USE:
 *
 * ========== OPTIONAL:
 * 
 */
var Swiss = {

  "development?" : (window.location.hostname==='localhost' || window.location.hostname==='127.0.0.1'),
  "production?"  : (window.location.hostname.indexOf(".com") > 1),
  "test?"        : ( window.location.hostname.indexOf(".com") < 0 && window.location.hostname != 'localhost' && window.location.hostname != '127.0.0.1'),
  log_it         : function(obj){
      if( Swiss["development?"] ) {
          console.log(obj)
          return true;
      };
      return false;
  },
  
  parse_int : function(obj) {
    return( parseInt(obj, 10) || 0 );
  },

  sanitize_cookie_name : function(str){
    return str.replace(/[^a-z0-9\-]/ig, '-');
  },

  store_cookie : function(key, val, raw_opts){
    var opts =  (raw_opts) ? raw_opts : { path : '/'};
    return $.cookie(key, val, opts);               
  },

  force_cache_clear : function(){
    var cookie_name = Swiss.sanitize_cookie_name( 'last-ajax-update' );
    var right_now   = (new Date()).getTime();
    $.cookie( cookie_name, right_now, { path : '/' } );
  },

  /* 
   * Based on the info. gathered at: http://stackoverflow.com/questions/158319/cross-browser-onload-event-and-the-back-button
   */ 
  clear_cache_if_requested : function(){
    var last_ajax_update_cookie_name = Swiss.sanitize_cookie_name( 'last-ajax-update' );
    var raw_last_ajax_update = $.cookie(last_ajax_update_cookie_name);
    var last_ajax_update     = ( raw_last_ajax_update ) ? parseInt(raw_last_ajax_update) : null;

  
    var default_timestamp = (new Date()).getTime();
    var the_timestamp_ele = $( '#the_timestamp' )[0];
    var the_timestamp = null;

    if( the_timestamp_ele )
      the_timestamp = parseInt( $( the_timestamp_ele ).text() );
    else
      the_timestamp = default_timestamp;
    
    $(window).bind("unload", function(){});
    
    if( last_ajax_update  &&  last_ajax_update > the_timestamp ) {
      window.location.reload(); 
    };    
  },


  /*
   * Returns True if an Ajax call is taking place.
   * Use Swiss.start_busy_status ans Swiss.end_busy_status
   * to manipulate busy status.
   *
   * @return {Bool} Returns either true or ralse.
   */
  'busy?' : function(){
    return (Swiss['ajax_status']) ? true : false;
  },

  start_busy_status : function() { Swiss['ajax_status'] = true; },
  end_busy_status : function() { Swiss['ajax_status'] = false; },
  
  swap_display : function(hide,show){
    if(hide && show ) {
      $(hide).hide();
      $(show).show(); 
    };
    
  }
};




/*
 * ========== HOW TO USE:
 *
 * ========== OPTIONAL:
 * 
 */ 
Swiss.loading = {
  page_finished :  function(){
    
    Swiss.tab.page_finished();
    
    // Set default radios, highlight radios, reset any forms.
    Swiss.form.page_finished();
    
  

    
    return Swiss.loading.switch_it();

  },
  
  switch_it : function(){
    var loading = $('#loading');
    var wrapper = $('#the_wrapper');
    var do_they_both_exist = (loading.length == 1 && wrapper.length == 1);
    loading.hide();
    wrapper.show();
    return wrapper;
  }
  
};



Swiss.email = {
    
  transform : function() {
    $.each(arguments, function(i, ele) {
      $(ele).each(function(j) {
        var new_email = '';
        new_email = $(this).html().replace(' [at] ', '@').replace(' -at- ', '@').replace(' [dot] ', '.').replace(' -dot- ', '.');
        $(this).html('<a href="mailto:'+new_email+'" title="Send me bug reports.">'+new_email+'</a>');
      });
    } );
  }
  
}; // === Swiss.email

/*
 * ========== HOW TO USE:
 *
 * ========== OPTIONAL:
 * 
 */ 
Swiss.object = {
  keys : function(obj){
    var the_keys = [];
    for(var i in obj){
      the_keys.push(i);
    }
    return the_keys;
  }
};



/*
 * ========== HOW TO USE:
 *
 * ========== OPTIONAL:
 * 
 */ 
Swiss.array = {
  last : function( arr ) {
    return arr[arr.length-1];
  }
};



/*
 * ========== HOW TO USE:
 *
 * ========== OPTIONAL:
 * 
 */ 
Swiss.error = {    
    report : function(obj){
                  return Swiss.log_it(obj)
              }, // end reportError

    toString : function(obj) {
                  // More stuf to come later.
                  // Until then...
                  return ""+obj; 
                }
}; // end Swiss.error



/*
 * ========== HOW TO USE:
 *
 * ========== OPTIONAL:
 * 
 */ 
Swiss.string = {

  toObject : function( str, keys ) {
      
    var new_obj = {};
    var tail    = str;
    var tail_name = keys[keys.length-1];
    
    for(var i =0; i < keys.length-1; i++){
      new_obj[keys[i]]   = jQuery.trim( tail.substring(0, tail.indexOf("\n")) );
      tail               = jQuery.trim( tail.replace( new_obj[keys[i]] , '')  ) ;
    };
    
    // Add leftover string as last part.
    new_obj[tail_name] = jQuery.trim(  tail  );
    
    return new_obj;
  },
  
  nl2br : function(str){ // from: http://snipplr.com/view/634/replace-newlines-with-br-platform-safe/

    if(jQuery.trim(str).length==0)
      return str;

    var text = encodeURIComponent(str);
    var re_nlchar = false;
    var no_nl_found = text.indexOf('%0D%0A') > -1 || text.indexOf('%0A') > -1 || text.indexOf('%0D') > -1;
    if(!re_nlchar)
      return str;

    var text_with_brs= text.replace( /%0D%0A/g, '<br />' ).replace( /%0A/g, '' ).replace( /%0D/g, '<br />' );  
    return( decodeURIComponent( text_with_brs ) );

  }

}; // Swiss.string



/*
 * ========== HOW TO USE:
 *
 * ========== OPTIONAL:
 * 
 */ 
Swiss.dom = {

  pick_one : function(){
    var target = null;
    for(var i = 0; i < arguments.length; i++)
      if(arguments[i].length > 0){
        target = $(arguments[i][0]);
        break;
      };
    
    return target;
  }, // ============================
  
  anchor2node : function(anchor_ele) {
    return jQuery( '#' + Swiss.array.last( $(anchor_ele).attr('HREF').split('#') ) );
  },
  
  /*
    Use this on a link that disappears and shows a block.
    Example:
      .qa_question
        <a href="#ele_id">Question?</a>
      ele_id.qa_answer
  */
  qa_answer : function( anchor_ele ){
    $(anchor_ele).parents('.qa_question').hide();
    Swiss.dom.anchor2node( $(anchor_ele) ).show();
    return $(anchor_ele);
  }

};



/*
 * ========== HOW TO USE:
 * Handle JavaScript hide/show tabs. Example:
 *   ul
 *     li.tab_selected
 *        a :href=>'#folder_1', :onclick=> 'Swiss.tab.select(this); return false;'
 *     li
 *     li
 *   div.tab_selected.folder_1!
 *   div.tab_unselected.folder_2!
 *
 * Give the folders a class of :tab_unselected to hide them.
 * It does not matter that UL has no class.
 * Class 'tab_selected' was chosen to prevent classing from possible
 * future features.
 *
 * ========== OPTIONAL:
 * :page_finished is already included in Swiss.loading.page_finished.
 * This method sets the UL to the last selected LI using cookies as
 * memory. This only works if UL has an :id attribute. The LI :id
 * attribute is ignored.
 * 
 */ 
Swiss.tab = {

  /* Accepts an unlimited number of selectors as
   * arguments. Iterates them and prepares them
   * for display.
   */
  page_finished : function(){
    Swiss.tab.__init_history__();
    Swiss.tab.__select_all_from_history__();
  },
  
  css : {
    selected   : 'tab_selected',
    unselected : 'tab_unselected'
  },
  
  history : {},
  history_for_other_pages : {},

  /*
   * The history is stored in the browser using this format:
   *   /some/page:#parent_id,3|#another_parent,2;/another/page:#parent_id,3|#another_parent_id,1
   */
  __init_history__ : function(){
          if( !$.cookie('swiss-tab-history') || $.cookie('swiss-tab-history') == '' )
            return Swiss.tab.history;
          $.each( 
              ($.cookie('swiss-tab-history') || '').split(';') , 
              function(i, val){
                var raw_pieces = val.split(':');
                var page_index = raw_pieces[0]
                var pieces     = raw_pieces[1].split('|');
                  
                $.each( pieces, function(j, parent_child){
                    var raw_split = parent_child.split(',');
                    var parent_id = raw_split[0];
                    var child_id  = raw_split[1];
                    if( page_index == Swiss.sanitize_cookie_name(window.location.pathname) ) {
                      Swiss.tab.history[parent_id] = child_id;
                    } else {
                      if( !Swiss.tab.history_for_other_pages[ page_index ] )
                        Swiss.tab.history_for_other_pages[page_index] = {};
                      Swiss.tab.history_for_other_pages[page_index][parent_id] = child_id;
                    };

                });
              } // === function(i, val)
          );

          return Swiss.tab.history;
  }, // === function: get_history

  /* Goes through tab history and selects the LI the use last
   * selected, as if the user clicked on the actual A in the LI.
   */
  __select_all_from_history__ : function( ul_ele_selector ){ 
     $.each( 
        
         Swiss.tab.history, 
        
         function( parent_id, child_position ){
           var li_target_ele = $(parent_id).children('LI')[ child_position];
           if( li_target_ele ) {
             var a_target_ele = $(li_target_ele).find('a')[0];
             if( a_target_ele)
               Swiss.tab.select( a_target_ele );
           };
         }

     ); // === $.each    
  }, // === function: select_all_from_history

  save_history : function(){
    var this_page_name = Swiss.sanitize_cookie_name(window.location.pathname);
    Swiss.tab.history_for_other_pages[ this_page_name ] = {};

    $.each( Swiss.tab.history, function( parent_id, position ){
      Swiss.tab.history_for_other_pages[ this_page_name ][ parent_id ] = position ;
    } );

    var entries = [];
    $.each( Swiss.tab.history_for_other_pages, function(page_index, family){
      var pairs = [];
      $.each( family, function( parent_id, li_pos ){
        pairs.push( parent_id + ',' + li_pos );
      });
      entries.push( page_index + ':' + pairs.join('|') );
    });

    Swiss.store_cookie( 'swiss-tab-history', entries.join(';') );

  }, // === function: save_history

  record_to_history : function( parent_container, li_position) {
   
    var parent_id = $(parent_container).attr('id');
    
    if( !Swiss.tab.history ||  parent_id == '' || !parent_id )
      return false;
    
    Swiss.tab.history[ '#' + parent_id ] = parseInt(li_position);

    Swiss.tab.save_history();

    return Swiss.tab.history;
  }, // === function: record_to_history

  
  'selected?' : function(ele){
    return jQuery(ele).is('.tab_selected');
  },
  
  select : function(current_link) {

    if(Swiss['busy?']())
      return false;

    current_link.blur();
        
    var UL = jQuery(current_link).parents('UL')[0];
    var LI = jQuery(current_link).parents('LI')[0];
        
    if(Swiss.tab["selected?"](LI))
      return false;
    
    // Go through each LI element to add/remove CSS select class.
    $( UL ).children('LI').each(function(index, li){

      var folder = Swiss.dom.anchor2node( $(li).find('A') );

      if(li == LI) {
        Swiss.tab.css_select(li, folder );
        $(folder).show();
        Swiss.tab.record_to_history( UL, index);
      } else {
        Swiss.tab.css_deselect( li , folder );
        $(folder).hide();
      };

    });
    
      
  }, // end select

  css_select : function(){
                 $.each( arguments, function(i, ele){
                    $(ele).addClass('tab_selected');
                    $(ele).removeClass('tab_unselected');
                 }); // === $.each
  },

  css_deselect : function(){
                   $.each( arguments, function(i, ele){
                       $(ele).addClass('tab_unselected');
                       $(ele).removeClass('tab_selected');
                    }); // == $.each
  }

}; // end Swiss.tab



/*
 * ========== HOW TO USE:
 *
 * ========== OPTIONAL:
 * 
 * 
 */ 
Swiss.vertical_tab = {

  css : {
    selected   : 'tab_selected',
    unselected : 'tab_unselected'
  },

  select : function(current_link){

    if(Swiss['busy?']())
      return false;

    current_link.blur();
        
    var ULpar = jQuery(current_link).parents('UL')[0];
    var LIpar = jQuery(current_link).parents('LI')[0];
    

    if(Swiss.tab["selected?"](LIpar))
      return false;

    // Try getting the border width of the link element to help
    // in positioning content block.
    var border_width = 0;
    var selected_anchor = $(ULpar).find('li.' + Swiss.vertical_tab.css.selected + ' a')[0];
    if(selected_anchor) {
      border_width =  parseInt($(selected_anchor).css('border-top-width')) ;
    } else {
      $(LIpar).addClass( Swiss.vertical_tab.css.selected);
      selected_anchor = current_link;
      border_width =  parseInt($(selected_anchor).css('border-top-width')) ;
      $(LIpar).removeClass( Swiss.vertical_tab.css.selected );
    };
      
    var folder = Swiss.dom.anchor2node(  current_link );

    // First, get the x and y offset coord. of anchor.
    var anchor_offset = $(LIpar).offset();

    // Second, get the height and width of anchor.
    var anchor_width = $(LIpar).width();
    var anchor_height = $(LIpar).height();

    // Third, calculate the new x and y coord. of folder.
    var new_left = anchor_offset.left + anchor_width - border_width;

    var new_top = anchor_offset.top - 15;

    // Fourth, set folder position to absolute and set new x/y coord.
    $(folder).css('position', 'absolute');
    $(folder).css('z-index', '-5');
    $(folder).css('top', new_top + 'px');
    $(folder).css('left', new_left + 'px');
    
    // Now show the element.
    return Swiss.tab.select(current_link);


  } // select

}; //  Swiss.vertical_tabs 


/*
 * ========== HOW TO USE:
 *
 * ========== OPTIONAL:
 * 
 */ 
Swiss.anchor = {

  /*
   * Similar to Swiss.form.submit, except it uses a 'get' request and assumes
   * there is no form, just the link acting as a button.
   *
   *  raw_link - An HTML anchor element or jQuery.
   *
   *  target   - HTML element or jQuery to be replace with retrieved data.
   *
   *  raw_opts - Override options for JQuery AJAX call. Except for 'success' and 'error'.
   *             You can also pass in other values to raw_opts to keep track of in your 
   *             'success_msg' and 'error_msg' functions. 
   *             You can set the following:
   *    
   *    success_msg - Optional function. 
   *                  Gets called with: html elements, AJAX status message, and AJAX options used.
   *    error_msg   - Optional function. 
   *                  Gets called with same arguments of success_msg.
   *                  The default is an alert box telling user to reload page.
   *
  */  
  submit : function(raw_link, raw_target,  raw_opts){
    
    var link   = $(raw_link);
    var target = $(raw_target);

    var default_opts = {
          url  : link.attr('href'),
          type : 'get', 
          data : {}
    };
    
    var opts = $.extend( default_opts, raw_opts || {} );
    
    opts.success = function(data, status_msg){
      
      var eles     = $(data);             
      var partial  = eles.filter('div.partial').contents();
      var msg_call = ( (eles.filter('div.error_msg')[0]) ? 'error_msg' : 'success_msg' ); 
      
      if( partial[0] )
        target.replaceWith( partial );

      Swiss.force_cache_clear();

      if(opts[msg_call] )
        opts[msg_call](eles, status_msg, opts);
      else if(msg_call == 'error_msg') {
        alert('Unknown error. Contact support or reload page and try again.'); 
      };

    };

    opts.error = function( request, status_msg, errorThrown ){ 
      alert('Unknown error. You might want to reload web page and try again.');
      Swiss.log_it(request);
      Swiss.log_it(status_msg);
      Swiss.log_it(errorThrown);
    };

    $.ajax( opts );     
    
    return link;    
  }
  
}; // ============================


/*
 * ========== HOW TO USE:
 * Check the documentation for Swiss.form.submit because
 * that is usually the only method you will be concerned 
 * with.
 *
 */ 
Swiss.form = {

  /*
   * Parameters:
   * opts : Optional. Hash with following values:
   *        reset : Selector string for forms to be set. Use commas 
   *                to separate multiple forms.
   * 
   */        
  page_finished : function(opts){
    
    // Prep any forms
    if(opts){
      if(opts['reset'])
        $(opts['reset']).each( function(i, form){ Swiss.form.reset( form, true); });
    };
    
    Swiss.form.load_drafts();


    // Make sure all radios are have a default value.
    $('form fieldset.radios').each(function(index, parent_ele ){
        Swiss.form.check_default_radio( parent_ele );
    });

    // Save drafts when down changes.
    $('form').keyup( Swiss.form.save_drafts );
    $('form input[type=radio], form select').click( Swiss.form.save_drafts );
  }, // end page_finished  

    
  
  /*
    Any options in :raw_opts that are unused are 
    passed onto Swiss.form.results and Swiss.form.errors.
    
    If no form is found, then the parent of :link_ele is 
    used as the form holder. (i.e., it will be applied a CSS class of :loading.)
    
    Options:
      :success_msg - Function accepting :form, :results, :opts.  Used if 
                     :results was a success.
      :error_msg   - Function accepting :form, :results, :opts. Used if 
                     :results contains an error msg because data was invalid.
      :url          - jQuery option.
      :type         - jQuery option.
      :data         - jQuery option.
      :success      - jQuery option.
      :error        - jQuery option.
      :resetForm    - Defaults to false.
  */  
  submit : function(link_ele, raw_opts){

    if(Swiss['busy?']())
      return false;

    // Prevent other parts of the web page from
    // working while Ajax is being called.
    Swiss.start_busy_status();

    var opts      = raw_opts || {};
    var link      = $( link_ele );
    var form      = link.parents('FORM');
    var status_msg = $(form).find('div.status_msg, div.status');
    
    // Show form is loading.
    $(form).addClass('loading');


    // Update default options with new options.
    var ajax_opts = $.extend({
        url  : form.attr('action'),
        type : 'post',
        data : form.serialize(),
        resetForm : false
    }, opts);

    ajax_opts.error = function( request, ajax_status_msg ){ 
        // Allow other forms and events to take place.
        Swiss.end_busy_status();

        // Update form status box.
        var new_vals = $(request.responseText);
        var new_error_msg =  ( (new_vals.filter('div.error_msg')[0]) ? new_vals.filter('div.error_msg')[0] : null);
        if( new_error_msg ){
           status_msg.empty().append( new_error_msg );
        } else {
           status_msg.html('<div class="error_msg">' + 
              '<div class="title">An unknown error has occurred.</div>' +
              '<div class="msg">Try again later.<br />Contact support if you have an urgent request.</div>' + 
              '</div>');
        };

        // Remove loading status.
        $(form).removeClass('loading');

        // Display error message if necessary.
        Swiss.error.report(request);    
        
        return form;
    };

    ajax_opts.success = function( data, ajax_status_msg ){ 
        // Allow other forms and events to take place.
        Swiss.end_busy_status();

        // Reset form.
        if( opts.resetForm == null || opts.resetForm)
          form[0].reset();
        
        // Remove loading class name.
        form.removeClass('loading');

        // Update status message.
        var new_vals          = $(data);
        var new_status_msg    = new_vals.filter('div.success_msg, div.error_msg');
        var update_status_msg = status_msg.length > 0 && new_status_msg.length > 0;
        
        if(!update_status_msg){ 
          return ajax_opts.error( { responseText : null }, 'Unknown error.');
        };
        
        
        status_msg.empty().append( new_status_msg );

        // --------- Call the callback function if any. ------------
        var msg_call        = new_vals.hasClass('success_msg') ? 'success_msg' : 'error_msg'; // i.e.: "success_msg" or "error_msg"

        if(opts[msg_call]) 
          opts[msg_call](form, new_vals, opts);
        
        // ---------- Make sure it reloads if back button is used. ------
        Swiss.force_cache_clear(); 

        // --------- RE-save form drafts except the one just processed. -------------
        Swiss.form.save_drafts( form[0]  );

        // ---------- Redirect if specified. ------------------------
        var redirect_url = new_vals.filter('div.redirect_to').text();

        if( redirect_url.length > 0 ){
          window.location.href = redirect_url;
          return false;
        };
    }; // end ajax_opts.success
    

    $.ajax( ajax_opts );
    
    return form;
  }, // ============================
  
  
  // =============================
  // Selects the first among a set of radio choices
  // Parameters:
  //    parent_ele - Parent element that holds the radios.
  // Returns:
  //    selected HTML element as a jQuery object.
  // =============================
  check_default_radio : function( parent_ele ){
    var ul = $(parent_ele);
    var selected = ul.find('input:radio:checked')[0];
    
    if(selected) {
      // Make sure it is highlighted.
      Swiss.form.select_radio(ul);
      return false;
    }
    
    var first_radio = ul.find('input:radio:first');
    first_radio.attr('checked', 'checked');
    // Highlight it.
    Swiss.form.select_radio(ul);
    
    return ul.find('input:radio:checked');
  }, // =============================
  
  select_radio : function(menu_ele){
    
    var menu      = $(menu_ele);
    var selected  = menu.find("input[@type='radio']:checked");
    var form      = menu.parents('FORM');
 
    // Set CSS class on LI element. (Radio holder.)
    menu.find('input:radio').each(function(index, input){
        
        var css_action = ( input == selected[0] ) ? 'addClass' : 'removeClass';
        
        $(input).parents('LI')[css_action]('selected');
        // form[css_action]( 'selected_' + $(input).attr('value'));
        
    }); // end menu.find
    
   }, // =============================

   expand_text_box : function(link_ele) {
      var link = $(link_ele);
      var fieldset = link.parents('fieldset');
      var text_box = fieldset.children('textarea');

      text_box.height( text_box.height() + 200 );

      return text_box;
   }, // ========== end expand_text_box
  

  /* Stores all forms (that have an :name attribute) in a cookie.
   * Ignores any form passed to it as an argument.
   */
  save_drafts : function( dont_save ){
    
    var serial_forms = [];
    var forms = $('form[name]');
    
    if(dont_save)
      $(dont_save).addClass('temp-dont-save');
    
    forms.each( 
        function( i, form_ele ){
          if( $(form_ele).attr('name') == '' && !$(form_ele).hasClass('temp-dont-save') )
            return false;
         serial_forms.push( $(form_ele).attr('name') + '==' + $(form_ele).serialize()  );
        } 
    ); // each
    
    Swiss.store_cookie('form-drafts', serial_forms.join('==='), { path : window.location.pathname, expires : 7 } );

    if(dont_save)
      $(dont_save).removeClass('temp-dont-save');

    return forms;       
  },  // ==== save_drafts


  load_drafts : function(){
    if( !$.cookie('form-drafts') )
      return false;
    var raw_drafts = $.cookie('form-drafts').split('===');
    $.each(raw_drafts, function(raw_draft_i, serialized_form_with_id){
      var raw_id_with_serial = serialized_form_with_id.split('==');
      var form_id = raw_id_with_serial[0];
      var content = raw_id_with_serial[1];
      var form = $('form[name=' + form_id + ']');
      if( !form[0] )
        return false;
      $.each( content.split('&'), function(content_i, pair){
        var raw_pairs = pair.split('=');
        var name = raw_pairs[0];
        var val  = raw_pairs[1];
        try {
          $( form[0].elements[name] ).val( [ decodeURIComponent(val.replace( /\+/g, ' ' )) ] );
        } catch(e) {
          // Do nothing.
          // If it doesn't load, it doesn't load.
          // :load_drafts is just there to save most of the text in a form
          // if the browser crashes.
        };
      } );
    } );
  }
}; // Swiss.form



// Make sure page reloads if needed.
Swiss.clear_cache_if_requested();








 
// * ****************************************************************************
// * Custom additions to the Element methods using mooTool's 'implement' method.
// * ****************************************************************************
// */
//Element.implement({

//    
//    getEyeColor : function (){
//        ele = this;
//        
//        var is_bgcolor      = function(color_string){ return $type(color_string)==='string' && color_string.indexOf('#') === 0; };
//        var ele_parent      = ele.getParent();
//        var bgcolor         = ele.getStyle('background-color');
//        var default_color   = '#fff';
//        
//        if(  is_bgcolor( bgcolor ) )
//            return bgcolor;
//        
//        while(  !is_bgcolor(bgcolor) &&  ele_parent){
//                bgcolor = ele_parent.getStyle('background-color');
//                ele_parent = ele_parent.getParent();
//        };
//        
//        return (is_bgcolor(bgcolor)) ?  bgcolor : '#fff';

//    }, // end getEyeColor

