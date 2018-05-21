// --------------------------------------------------------------------------------------------------------------
// Put all event observers here for page. -----------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
	Event.observe(window,'load', index_apply_behaviours);

// --------------------------------------------------------------------------------------------------------------
// Define variables for page here, including behaviour rules ----------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
	var index_page_rules = {
		'#main_column div.datetime' : function (ele) {ele.innerHTML=format_publish_date(ele.title);} ,
		'span.alert_msg': function(ele){ ele.onclick = function(){ if(this.title) alert(this.title); } }
	}; // end var page_rules

// --------------------------------------------------------------------------------------------------------------
//  Put all functions for this page here ------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
	function index_apply_behaviours(){
	    Behaviour.list = new Array();
        Behaviour.register(index_page_rules);
        Behaviour.apply();
	}; // end function apply_behaviours
	
	function index_set_heart_link_datetime (ele) { 
		var dt = new Date();
		dt.setTime(Date.parse(ele.title));
	    ele.innerHTML = dt.toLocaleString().replace(/\:00 /,' ');
	}; // end function set_heart_link_datetime


