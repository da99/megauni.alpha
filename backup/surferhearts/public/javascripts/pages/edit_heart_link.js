
// --------------------------------------------------------------------------------------------------------------
// Put all event observers here for page. -----------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
Event.observe(window, 'load', create_text_editor, false);
Event.observe(window, 'load', apply_behaviour_rules, false);
Event.observe(window, 'load', setup_calendar,  false);


// --------------------------------------------------------------------------------------------------------------
// Define variables for page here, including behaviour rules ----------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
var page_rules = {
    'div.textarea' : function(ele){ ele.onclick=function(){HeartTextEditor.show_text_editor(this); return false;}},
    'div.fld_date input' : function(ele){ ele.value = HeartForms.get_human_date(ele.value);},
    'button.btn_update'  : function(ele){ ele.onclick = function(){HeartTextEditor.close_text_editor();submit_edit_form(this,'update');return false;} },
    'button.btn_delete'  : function(ele){ ele.onclick = function(){HeartTextEditor.close_text_editor();submit_edit_form(this,'delete');return false;} }
    
}; // end var page_rules

// --------------------------------------------------------------------------------------------------------------
//  Put all functions for this page here ------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
function apply_behaviour_rules(){
    Behaviour.register(page_rules);
    Behaviour.apply();
}; // end function apply_behaviour_rules

function setup_calendar(){
                      var dt = new Date();
                      var tz = (dt.getTimezoneOffset()/60);
                      var tz_sign = (tz > 0) ? '-' : ((tz<0) ? '+' : '' ) ;
                      var tz_zero_prefix = (tz < 10) ? '0' : ''  ;
                      tz = tz_sign + tz_zero_prefix + tz + '00';

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
}; // end function setup_calendar
function create_text_editor(){
    HeartTextEditor.set_toolbarset('Admin');
    HeartTextEditor.create_text_editor('text_editor');
}; // end function create_text_editor

function submit_edit_form(ele, sEditType){
    ele.disabled= true;
    window.originalButtonMsg = ele.innerHTML;
    window.originalButton = ele;
    ele.innerHTML = 'Wait...';
    


    var oForm = ele.parentNode;
    var oVals = false;
    var sAction = false;

    if(oForm.tagName!='FORM') {
        alert('Form not found');
        return false;
    }
    oVals = $H(HeartForms.get_form_values(oForm)).toQueryString();

    sAction=oForm.action;
    if(sEditType=='delete') {
        if(!ele.getAttribute('title')) {
            alert('Delete message not found.');
            return false;
        }
        if(!confirm(ele.title)) {
            reset_form_buttons()
            return false
        }
        
        sAction = sAction.replace(/\/update/, '/delete');
    }
    
    window.onFormSuccess= (oForm.elements['onFormSuccess']) ? oForm.elements['onFormSuccess'].value : window.location.href;

    new Ajax.Request(sAction, {
                                method: 'post', 
                                postBody: oVals, 
                                onFailure: function(request){
                                                                alert("An unknown error occurred: \n"+request.responseText);
                                                                reset_form_buttons();
                                                             }, 
                                onSuccess: function(request){ 
                                                                var oVals = request.responseText.parseJSON();
                                                                if(oVals.success) window.location.href=window.onFormSuccess; 
                                                                else {
                                                                    alert($H(oVals).values().join("\n"));
                                                                    reset_form_buttons();
                                                                } 
                                                             }  
                                } );
    return false;
}; // end function submit_edit_form


function reset_form_buttons () {
    if(window.originalButton) {
        window.originalButton.disabled=false;
        window.originalButton.innerHTML = window.originalButtonMsg;
    }
}; // end function reset_form_buttons

// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------