// --------------------------------------------------------------------------------------------------------------
// Put all event observers here for page. -----------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
Event.observe(window, 'load', create_text_editor, false);
Event.observe(window, 'load', setup_calendar,  false);
Event.observe(window, 'load', apply_mediaset_behaviour_rules, false);


// --------------------------------------------------------------------------------------------------------------
// Define variables for page here, including behaviour rules ----------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
HeartForms.cache.altered_textareas_only = true;
var original_submit_button = false;
var original_submit_msg = false;
var mediaset_rules = {
    
	'div.textarea' : function(ele){ ele.onclick=function(){HeartTextEditor.show_text_editor(this); return false;}},
    
	'#form_update_mediaset' : function(ele){ele.reset();},
	'#form_update_mediaset input' : function(ele){ if(ele.parentNode.className == 'fld_date') ele.value = HeartForms.get_human_date(ele.value);},
    '#form_update_mediaset button.btn_submit': function(ele){ele.disabled=false; ele.onclick=submit_update_mediaset},
    '#form_update_mediaset button.btn_delete': function(ele){ele.disabled=false; ele.onclick=submit_delete_mediaset},
    
    '#form_update_photos button.btn_submit': 	function(ele){ele.disabled=false; ele.onclick=submit_update_photos;},
	'#form_update_photos a.btn_delete': 		function(ele){ele.disabled=false; ele.onclick=submit_delete_one_photo;},
	
	'#form_upload_mediaset_file button.btn_submit' : function(ele){ele.disabled=false; ele.onclick=submit_upload_mediaset_file}
    
}; // end var mediaset_rules



// --------------------------------------------------------------------------------------------------------------
//  Put all functions for this page here ------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
function submit_upload_mediaset_file() {
    disable_form_buttons(this, 'Uploading...');
	HeartForms.get_form_parent(this).elements['filename_on_client'].value = HeartForms.get_form_parent(this).elements['mediaset_file'].value;
    
	HeartForms.get_form_parent(this).submit(); 
    return false;
};

function submit_update_mediaset () {
	HeartTextEditor.close_text_editor();  
    disable_form_buttons(this, 'Updating...');
	
    // get and save form values 
    var oForm = HeartForms.get_form_parent(this);
    
    if(!oForm) { 
        alert('FORM not found.'); 
		reset_form_buttons();
        return false;
    }
	

    // submit form values
    new Ajax.Request(oForm.action, {
        method: 'post', 
        postBody: $H(HeartForms.get_form_values(oForm)).toQueryString(), 
        onFailure: handle_failed_ajax_request, 
        onSuccess: handle_successful_ajax_request   
    } ); 
	
    return false;
};

function submit_mediaset_add_files() {
	
    disable_form_buttons(this,'Adding Files...');
	if( confirm( this.title ) ) {
		window.location.href = this.value;
	} else 
		reset_form_buttons();
	
	return false;
};

function submit_delete_mediaset() {
    disable_form_buttons(this, 'Deleting...');
	
	if( confirm(this.title) ) {
		window.location.href = this.value;
	} else	
		reset_form_buttons();
	
	return false;
};


function submit_update_photos(){
    HeartTextEditor.close_text_editor(); 
	disable_form_buttons(this,'Updating...');
	
	// get and save values
	var oForm = HeartForms.get_form_parent(this);
	var divs = document.getElementsByClassName( 'textarea', oForm );
	
	divs.each( function(ele){
		if( Element.hasClassName(ele,'altered') ) {
			// if hidden field is not found, create it and append it
			if(!oForm.elements[ele.title]) {
				var hiddenField = document.createElement('INPUT');
				hiddenField.type = 'hidden';
				hiddenField.name =  ele.title;
				oForm.appendChild(hiddenField);
			}
			oForm.elements[ele.title].value = ele.innerHTML;	
		}
	});

	oForm.submit();
    return false;
};

function submit_delete_one_photo() {
	if(confirm(this.title)) {
		return true;
	}
	return false;
};

function handle_failed_ajax_request (request) {
    alert("An unknown error occurred: \n"+request.responseText);
	reset_form_buttons();
};

function handle_successful_ajax_request (request) {

    var oVals = request.responseText.parseJSON();
    if(oVals.success) 
		window.location.reload(); 
    else {
        alert($A(oVals.errors).join(".\n")+'.');
        reset_form_buttons();
    } 

};

function disable_form_buttons (oButton, sMsg) {
	window.original_submit_button = oButton;
    window.original_submit_msg = oButton.innerHTML;
    oButton.innerHTML = sMsg;
    oButton.disabled=true;
};
function reset_form_buttons () {
    window.original_submit_button.innerHTML = window.original_submit_msg;
    window.original_submit_button.disabled=false;
    window.original_submit_button = false;
};

function apply_mediaset_behaviour_rules () {    
    Behaviour.register(mediaset_rules);
    Behaviour.apply();
}; // end function apply_behaviour_rules

function setup_calendar () {
      Calendar.setup(
        {
          inputField  : "published_on",         // ID of the input field
          ifFormat    : ("%a %b %d %I:00 %p "+HeartForms.get_user_timezone()+" %Y"),    // the date format
          button      : "published_on_popup_calendar",       // ID of the button
          showsTime   : true,
          timeFormat  : 12,
          align       : 'Br'
        }
      );
}; // end function setup_calendar

function create_text_editor () {
    HeartTextEditor.set_toolbarset('Admin');
    HeartTextEditor.create_text_editor('text_editor');
}; // end function create_text_editor

