
// --------------------------------------------------------------------------------------------------------------
// Put all event observers here for page. -----------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
Event.observe(window, 'resize', redraw_all_editors,   false);
Event.observe(window, 'load', apply_behaviour_rules, false);
Event.observe(window, 'load', setup_calendar,  false);
Event.observe(window, 'load', create_text_editor, false);

Event.observe(window, 'load', function(){initLightbox();}, false);
// --------------------------------------------------------------------------------------------------------------
// Define variables for page here, including behaviour rules ----------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
var orig_button = false;
var orig_button_msg = false;
var PageCache = {};
var myrules = {
	'#site_preferences a' : function(ele){
		if(ele.getAttribute('rel'))
		  ele.onclick = function(){HeartTextEditor.close_text_editor();show_edit_block(this); return false;};
	},
	'#articles_list a' : function(ele){
		if(ele.getAttribute('rel'))
		  ele.onclick = function(){  HeartTextEditor.close_text_editor();show_edit_block(this); return false;};
	},
	'#non_active_heart_links a' : function(ele){
		if(ele.getAttribute('rel'))
		  ele.onclick = function(){HeartTextEditor.close_text_editor();show_edit_block(this); return false;};
	},
	
	'#upcoming_heart_links a': function(ele){
	   if(ele.getAttribute('rel'))
	       ele.onclick = function(){HeartTextEditor.close_text_editor();show_edit_block(this); return false;}
	},
	
	'#admin_add a': function(ele){
	   ele.onclick=function(){HeartTextEditor.close_text_editor(); show_add_block(this); return false;};
	   if(ele.getAttribute('rel') && !PageCache.currentAddBlock) 
	       PageCache.currentAddBlock=$(ele.getAttribute('rel'));
	   
	},
	'div.datetime': function(ele){ ele.innerHTML = format_publish_date(ele.title); },
	'div.edit_block div.header a' : function(ele){ 
	           ele.onclick = function(){                   
	                        HeartForms.close_edit_block();
	                        PageCache.currentLink = false;
                            HeartTextEditor.close_text_editor();
                            return false;
                            };
	}, 
	
	'button' : function(ele) {
	   if(ele.className=='btn_upload') {
	       ele.onclick = function(){
		   		disable_form_buttons(this,'Uploading...');
					var oForm = HeartForms.get_form_parent(this);
					oForm.elements['filename_on_client'].value =  oForm.elements['photo'].value ; 
					oForm.submit();
					return false;
				};
	   } else if (ele.className=='btn_reload') {
	       ele.onclick =function(){window.location.reload();return false;};
	   } else if(ele.parentNode.parentNode.className=='edit_block' || ele.parentNode.parentNode.parentNode.className=='edit_block') {
    	   if(ele.className=='btn_update')
    	       ele.onclick = function(){HeartTextEditor.close_text_editor();return submit_edit_block_form(this, 'update');}

    	   if(ele.className=='btn_delete')
    	       ele.onclick = function(){HeartTextEditor.close_text_editor();return submit_edit_block_form(this, 'delete');}
	   } else if(ele.className=='btn_create' || ele.className=='btn_submit' ) {
	       ele.onclick = function(){
	                           HeartTextEditor.close_text_editor();
	                           return submit_create_block_form(this);

	                       }
	        }
	
	},
	
	'div.textarea': function(ele){
	   ele.onclick = function(){HeartTextEditor.show_text_editor(this); return false;};
	}
        	
}; // end of Object myrules

// --------------------------------------------------------------------------------------------------------------
//  Put all functions for this page here ------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
function findParentTagName(oEle, sTagName) {
    oParent = oEle.parentNode;
    while(oParent  && oParent.tagName != sTagName)
        oParent = oParent.parentNode;
    return oParent;
}; // end function findParentTagName




function create_text_editor() {
    HeartTextEditor.set_toolbarset('Admin');
    HeartTextEditor.create_text_editor('text_editor');
};

function setup_calendar() {
      var dt = new Date();
      var tz = (dt.getTimezoneOffset()/60);
      var tz_sign = (tz > 0) ? '-' : ((tz<0) ? '+' : '' ) ;
      var tz_zero_prefix = (tz < 10) ? '0' : ''  ;
      tz = tz_sign + tz_zero_prefix + tz + '00';
      
      Calendar.setup(
        {
          inputField  : "mediaset_published_on",         // ID of the input field
          ifFormat    : ("%a %b %d %I:00 %p "+tz+" %Y"),    // the date format
          button      : "mediaset_popup_calendar",       // ID of the button
          showsTime   : true,
          timeFormat  : 12,
          align       : 'Br'
        }
      );
      
      Calendar.setup(
        {
          inputField  : "heart_link_published_on",         // ID of the input field
          ifFormat    : ("%a %b %d %I:00 %p "+tz+" %Y"),    // the date format
          button      : "popup_calendar",       // ID of the button
          showsTime   : true,
          timeFormat  : 12,
          align       : 'Br'
        }
      ); 
      Calendar.setup(
        {
          inputField  : "edit_heart_link_published_on",         // ID of the input field
          ifFormat    : ("%a %b %d %I:00 %p "+tz+" %Y"),    // the date format
          button      : "edit_heart_link_published_on_popup_calendar",       // ID of the button
          showsTime   : true,
          timeFormat  : 12,
          align       : 'Br'
        }
      );
      
};
function apply_behaviour_rules(){

    Behaviour.register(myrules);
    Behaviour.apply();
}; // end function apply_behaviour_rules



function redraw_all_editors() {
     if(PageCache.currentLink) 
        show_edit_block(PageCache.currentLink);
     HeartTextEditor.show_text_editor();
}; // end function redraw_edit_block


function show_add_block(oLink){
    
    if(PageCache.currentAddBlock)
        PageCache.currentAddBlock.style.display='none';
    PageCache.currentAddBlock = $(oLink.getAttribute('rel'));
    PageCache.currentAddBlock.style.display='block';
    return false;
}; // end function show_add_block

function show_edit_block (oLink) {
    oLink = (oLink.tagName) ? oLink   : this ;
    
    if(oLink == PageCache.currentLink)
        return false;
        
    HeartForms.set_edit_block(oLink.getAttribute('rel'));
    PageCache.currentLink = oLink;
    var pos = Position.cumulativeOffset(oLink);
    var dim = Element.getDimensions(oLink);
    var cacheName = oLink.getAttribute('rel') +pos[1] + 'px';
    var vals = HeartForms.get_saved_form_values( cacheName);
    
    // handle special case for the unusual height of the edit_heart_link block
    if(oLink.getAttribute('rel')=='edit_heart_link') {
        pos[1] = pos[1]-200;
        
    }
    
    if(  vals ) {
        HeartForms.show_edit_block('show', {top: pos[1],left: (pos[0]+dim.width) } );
        HeartForms.show_edit_block('load', vals );
    }else {
    
        HeartForms.show_edit_block( 'loading', {top: pos[1] , left: (pos[0]+dim.width) });
        
        new Ajax.Request(oLink.href, { 
            method: 'get', 
            onFailure: show_edit_block_failure, 
            onSuccess: show_edit_block_read_results 
            } );
        
    }
    return false;
}; // end function show_edit_block


function submit_create_block_form(oBtn) {
    

   window.currentButton = oBtn;
   window.originalButtonValue = oBtn.innerHTML;
   oBtn.innerHTML='Wait...'; 
   oBtn.disabled = true; 
   
   var oVals = false;
   var oFORM = findParentTagName(oBtn,'FORM');
   if(!oFORM) {
       alert('Create form not found.')
       return false;
   }
   HeartForms.set_textareas(oFORM);
   oVals =  $H(HeartForms.get_form_values(oFORM)).toQueryString();
   new Ajax.Request(oFORM.action, {
                                    method:'post', 
                                    postBody: oVals, 
                                    onFailure: function(request){ alert( request.responseText ); }, 
                                    onSuccess: function(request){
                                                    var results = parseJSON(request.responseText);
                                                    if(results.success)
                                                        window.location.reload();
                                                    else {
                                                        alert( $A(results.errors).join("\n") );
                                                        window.currentButton.innerHTML = window.originalButtonValue;
                                                        window.currentButton.disabled = false;
                                                        window.currentButton = false;
                                                    }
                                               }
                                    });
   
   return false;
} ; // end function submit_create_block_form


function submit_edit_block_form(oBtn, sType) {
    HeartForms.show_edit_block('loading');
    
    var oForm = findParentTagName(oBtn, 'FORM');
    var oVals = false;
    var sAction = '';

    if(!oForm) {
        alert('Form not found');
        HeartForms.show_edit_block('show');
        return false;
    }
    oVals = $H(HeartForms.get_form_values(oForm)).toQueryString();
    sAction = oForm.action;
    if(sType=='delete') {
        sAction = sAction.replace(/\/update\//, '/delete/');
        if(!oBtn.getAttribute('title') ) {
            alert('Delete message not found.');
            HeartForms.show_edit_block('show');
            return false;
        }
        
        if(!confirm(oBtn.title)){
            HeartForms.show_edit_block('show');
            return false;
        }

    }
    
    new Ajax.Request(sAction, {method: 'post', postBody: oVals, onFailure:show_edit_block_change_unknown_error, onSuccess: show_edit_block_change_results  } );
    return false;
}; // end function submit_delete_edit_block


function show_edit_block_failure(request) {
alert('test');
    HeartForms.show_edit_block('errors', { unknown: 'Unknown error.' });
};

function show_edit_block_read_results(request){
    var results = parseJSON(request.responseText);
    var cacheName = HeartForms.get_edit_block().id+HeartForms.get_edit_block().style.top;
    if(results.errors)
        // HeartForms.show_edit_block('errors', results.errors);
        alert(  $A(results.errors).join("\n")  );
    else {
        HeartForms.show_edit_block('load', results.results );
        HeartForms.save_form_values( cacheName, results.results);
        
        // handle special case for edit_heart_link block
        if(results.results.img && HeartForms.get_edit_block().id=='edit_heart_link'){
            $('edit_heart_link_image').innerHTML='<img src="'+ results.results.img+'" />';
        }
    }
    return false;
}; // end function show_edit_block_read_results

function show_edit_block_change_results(request) {
    var results = parseJSON(request.responseText );
    if(results.errors) { 
        HeartForms.show_edit_block('show' );
        alert( $A(results.errors).join("\n") );
    } else {
        alert(results.success_msg);
        window.location.reload();
    }
    return false;
}; // end function show_edit_block_change_results


function show_edit_block_change_unknown_error (request) {
    
    alert('An unknown error occurred.');
    HeartForms.show_edit_block('show', {preventAutoHide: true} );
    alert(request.responseText);
}; // end function show_edit_block_change_unknown_error

function disable_form_buttons(oButton, sMsg) {
	orig_button = oButton;
	orig_button_msg = oButton.innerHTML;
	orig_button.disabled= true;
	orig_button.innerHTML = sMsg;
};

function reset_form_buttons(){
	if(orig_button) {
		orig_button.disabled=false;
		orig_button.innerHTML = orig_button_msg;
		orig_button=false;
	}
};

// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------

// CODE DESIGN RULE: SIMPLE LIBRARIES, MESSY CONTROLLERS
// CODE BY: D.A. - 12/2006.  email me if you are single, female, and have a nice smile.
// HARDCORE CAPITALISM: treat the customer the way you would like to be treated.  such a radical concept
//   among the MBA-istas.