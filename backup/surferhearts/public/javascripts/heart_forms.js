var HeartForms = new Object();
/********************************************************************************************/
HeartForms.cache = { currentBlock: false, currentForm: false, formValues: {} };
HeartForms.cache.onshow = function(){};
HeartForms.cache.onclose = function(){};
HeartForms.cache.altered_textareas_only = false; // if set to TRUE, then only DIVs that have include 'altered' in className will be recorded.
/*
    Function: set_edit_block
*/
HeartForms.set_edit_block = function (oBlock){
    HeartForms.close_edit_block();
    if(oBlock = $(oBlock))
        HeartForms.cache.currentBlock = oBlock;
    else
        alert('Block not found.');
    return false;
}; // end function set_edit_block

/*
    Function: get_edit_block
        See <set_edit_block>.
*/
HeartForms.get_edit_block = function() {
    return HeartForms.cache.currentBlock;
}; // end function get_edit_block 

/*
    Function: close_edit_block
    Parameters:
        none.

*/
HeartForms.close_edit_block = function () {
    if (HeartForms.cache.currentBlock) {
        HeartForms.cache.currentBlock.style.display = 'none';
        HeartForms.cache.currentBlock = false;
    }
    
    HeartForms.cache.onclose();
    return false;
     
}; // end function close_edit_block

/*
    Function: show_edit_block
    Parameters:
        oBlock - ID or object of editing block.
        sType  - Desired action. ('loading', 'success', 'errors', 'show')
        oVals  - Optional.  Values to load block for 'errors' or 'success'.

*/
HeartForms.show_edit_block = function (sType, oVals) {

        
        // set default values
        if(!oVals)
			oVals = {};
			
        // Hide all parts of block except for the header
        if(!oVals.preventAutoHide) {
            oBlock = HeartForms.cache.currentBlock;
            oBlock.style.display='block';
            $A(oBlock.childNodes).each( function(node){
                    if(node.nodeType==1)
                        node.style.display=( node.className == 'header') ? 'block' : 'none' ;
                });
            
        }

        
        // Position block 
        if( oVals.top && oVals.left) {
    		oBlock.style.top=oVals.top+'px';
    		oBlock.style.left=oVals.left+'px';
        }
		

        
        // Handle desired action
        switch(sType) {

            case 'show':
                document.getElementsByClassName( 'body', oBlock )[0].style.display='block';
                break;
            case 'success':
                var oSuccess = document.getElementsByClassName( 'success', oBlock )[0];
                var oSuccessMsg = (oSuccess) ? document.getElementsByClassName('success_msg', oBlock)[0] : false;
                if(oSuccessMsg) {
                    oSuccessMsg.innerHTML = oVals.successMsg;
                    oSuccessMsg.innerHTML = "Success!";
                }
                oSuccess.style.display='block';
                break;
            case 'load':
                if(!oVals.form)
                    oVals.form = HeartForms.cache.currentBlock.getElementsByTagName('FORM')[0];
                HeartForms.load_form(oVals.form, oVals);
                HeartForms.show_edit_block('show');
                break;
            case  'errors':
                  var err_txt = '';
                  if(vals.errors) {
                    ($A(vals.errors)).each(function(node){ err_txt += '<LI>'+node+'</LI>';  });     
                  } else 
                    err_txt+='<LI>Info. could not be retrieved. Try again later.</LI>';
                  
                  oErrorsBlock = document.getElementsByClassName( 'errors',oBlock)[0];
                  oErrorsBlock.innerHTML = '<UL>'+err_txt+'</UL>';
                  oErrorsBlock.style.display='block';
                break;
            default:
                document.getElementsByClassName( sType, oBlock )[0].style.display='block';
        }; // end switch    
        
        // reset any values
        oVals.preventAutoHide= false;
        
        HeartForms.cache.onshow();
        return false;
            
}; // end function load_form

/*
    Function: save_form_values
*/
HeartForms.save_form_values = function (sName, oVals) {
    HeartForms.cache.formValues[sName]=oVals;
    return oVals;
}; // end function save_form_values

/*
    Function: get_saved_form_values
*/
HeartForms.get_saved_form_values = function (sName) {
    return (HeartForms.cache.formValues[sName]) ? HeartForms.cache.formValues[sName] : false;
}; // end function get_saved_form_values



/*
    Function: get_form_values
        Returns the values of a form as a JS object.
*/				
HeartForms.get_form_values = function (o_frm) {

    var inputs   = $A(o_frm.getElementsByTagName('INPUT'));
    var txt_area = document.getElementsByClassName('textarea', o_frm );
    var selects  = $A(o_frm.getElementsByTagName('SELECT'));
    var checkbox_counter = 0;
    var fld_id   = ''  ,  fld_type= ''   ,   flds = new Object   ;
    flds.has_files = false;
    flds.has_password = false;


    // add form name
    flds['form_name'] = o_frm.name;
    
    // Get values of select/drop-down menus    
    selects.each( function(node){ flds[node.name] = node.value; } );
    
    // loop through all textareas
    txt_area.each( function(node) {
                if( node.tagName == 'DIV' && node.getAttribute('title') && (!HeartForms.cache.altered_textareas_only || Element.hasClassName(node, 'altered') ) )
                            flds[node.getAttribute('title')] = node.innerHTML;
                    } );

    // loop through all divs and deal with the ones with field_names
    inputs.each(function(node){
      switch(node.type) {
  
        case 'hidden':
            flds[node.name] = node.value;
        break;
        
        case 'checkbox':
            if( !flds[node.parentNode.parentNode.getAttribute('title')] )
                flds[node.parentNode.parentNode.getAttribute('title')] = new Array();
			if(node.checked)
        		flds[node.parentNode.parentNode.getAttribute('title')][checkbox_counter++]=node.value;
        	break;
        
        case 'text':
        
            if(!node.disabled ) {
                    flds[node.name] = node.value;
            } 

            break;
      } // end switch
    });

  return flds;
}; // end function get_form_values



/*
	Function: set_textareas
		Takes the values of all DIVs in a FORM that were used to replace textareas and
		inserts them as hidden INPUTs.  The 'title' attribute of the DIV is used as the 
		name of the hidden INPUT.
		
	Parameters:
		o_frm - Required FORM object.
*/
HeartForms.set_textareas = function (o_frm) {
    // set values of TEXTAREA
    var txt_areas = o_frm.getElementsByTagName('DIV');
    var hidden_input = '';
    for(var i = 0; i < txt_areas.length; i++ )
      if(txt_areas[i].className=='textarea' && txt_areas[i].getAttribute('title') ) {
            if( o_frm.elements[txt_areas[i].getAttribute('title')]  )
                o_frm.elements[txt_areas[i].getAttribute('title')].value=txt_areas[i].innerHTML;
            else {
              hidden_input = document.createElement('INPUT');
              hidden_input.type='hidden';
              hidden_input.name=txt_areas[i].getAttribute('title');
              hidden_input.value=txt_areas[i].innerHTML;
              o_frm.appendChild(hidden_input);
            }
      }
}; // end function set_textareas

/*
    Function: load_form
        Takes an object with keys and values and loads it into a form.

*/
HeartForms.load_form = function (o_frm, o_vals)   {

    var sName      = '';
    var inputs     = o_frm.getElementsByTagName('INPUT') ;
    var txt_areas  = o_frm.getElementsByTagName('DIV');
    var selects    = o_frm.getElementsByTagName('SELECT');

    for(var i=0; i < inputs.length; i++ )
        if( inputs[i].name && (inputs[i].type=='text' || inputs[i].type=='hidden') ){
            sName = inputs[i].name;
            if( o_vals[sName]){
               inputs[i].value = o_vals[sName];
              if(inputs[i].name.indexOf('_on')>4)
                inputs[i].value = HeartForms.get_human_date(inputs[i].value);
            }
        }
        
    for( i = 0; i< txt_areas.length; i++)
      if(txt_areas[i].className=='textarea'){
        if(txt_areas[i].getAttribute('title') && o_vals[txt_areas[i].getAttribute('title')] )
          txt_areas[i].innerHTML=o_vals[txt_areas[i].getAttribute('title')];
        else
          txt_areas[i].innerHTML='';
      }



    for( i = 0; i < selects.length; i++ )
      if( selects[i].name && o_vals[selects[i].name] )
        for(var j = 0; j < selects[i].options.length; j ++ ) {
          if( o_vals[selects[i].name] == selects[i].options[j].value )
            selects[i].options[j].selected=true;
          else
            selects[i].options[j].selected=false;
        }

        
    return false;

}; // end function load_form
/*
	Function: get_human_date
*/
HeartForms.get_human_date = function (s_datetime) {

    var Days = new Array('Sun','Mon','Tue','Wed',
    	'Thur','Fri','Sat');
    var Months = new Array('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
    var today = new Date();
    today.setTime(Date.parse(s_datetime));
    var Year = ((today.getYear()>100) ? (today.getYear()-100) : today.getYear())  + (((today.getYear() % 100) < 38) ? 2000 : 1900);
    var Month = HeartForms.add_leading_zero(today.getMonth()+1);
    var MonthName= Months[today.getMonth()];
    var DayName = Days[today.getDay()];
    var Day = HeartForms.add_leading_zero(today.getDate());
    var Hours = HeartForms.add_leading_zero( ( (today.getHours()>12) ? today.getHours() % 12 : today.getHours()  ) );
    var Minutes = HeartForms.add_leading_zero(today.getMinutes());
    var Seconds = HeartForms.add_leading_zero(today.getSeconds());
    var AMPM = ( today.getHours()  >= 12 ) ? ' PM' : ' AM';

    return DayName +' ' + MonthName + ' ' + Day + ' ' + ' ' + Hours + ':'+ Minutes  + AMPM  + ' -' + HeartForms.add_leading_zero(today.getTimezoneOffset()/60) + '00' + ' ' + Year
};

HeartForms.add_leading_zero = function(iNum) {return ((parseInt(iNum)<10)?'0':'')+iNum;};

// Returns: A string in the format of '-0600' or '-1000'
HeartForms.get_user_timezone = function() {
      var dt = new Date();
      var tz = (dt.getTimezoneOffset()/60);
      var tz_sign = (tz > 0) ? '-' : ((tz<0) ? '+' : '' ) ;
      var tz_zero_prefix = (tz < 10) ? '0' : ''  ;
      tz = tz_sign + tz_zero_prefix + tz + '00';
      return tz;
};

HeartForms.get_form_parent = function(ele){
    var limit = 5;
    
    for(var i =0; i<=limit; i++) {
        if(ele.parentNode && ele.parentNode.tagName=='FORM')
            return ele.parentNode;
        else
            ele=ele.parentNode;
    }
	
	if(!oFORM || oFORM.tagName != 'FORM')
		return false;
};
