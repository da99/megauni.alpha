// --------------------------------------------------------------------------------------------------------------
// Put all event observers here for page. -----------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
	Event.observe(window,'load', news_sidebar_apply_behaviours);

// --------------------------------------------------------------------------------------------------------------
// Define variables for page here, including behaviour rules ----------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
	var news_sidebar_page_rules = {
		// '#upcoming_heart_links div.datetime' : function (ele) {set_heart_link_datetime(ele);} ,
		'#form_search_website' : function (ele) { 
                ele.getElementsByTagName('INPUT')[1].onclick=function(){ 
                    return search_for_keywords(this); 
                }; 
            }
	}; // end var page_rules

// --------------------------------------------------------------------------------------------------------------
//  Put all functions for this page here ------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
	function news_sidebar_apply_behaviours(){
	    Behaviour.list = new Array();
        Behaviour.register(news_sidebar_page_rules);
        Behaviour.apply();
        Behaviour.list = new Array();
	}; // end function apply_behaviours
	
	function set_heart_link_datetime (ele) {
		var dt = new Date();
		dt.setTime(Date.parse(ele.title));
		var dtNow = new Date();
		var iDays = parseInt(  (Date.parse(ele.title)-dtNow.getTime())/(1000*60*60*24) );
	    var iHours = parseInt(  (Date.parse(ele.title)-dtNow.getTime())/(1000*60*60) ) - iDays;
	    var iMinutes = parseInt(  (Date.parse(ele.title)-dtNow.getTime())/(1000*60) ) - (iHours*60);
	    if(iDays)
	       ele.innerHTML = '(in ' + iDays + ( (iDays==1) ? ' day)' : ' days)');
	    else if (iHours > 12 && iHours < 23)
	       ele.innerHTML = '(in less than 1 day)';
	    else
	       ele.innerHTML = '(in ' + ( (iHours) ? (iHours + ' hrs. ') : '' ) + iMinutes + ' mins.)';
	}; // end function set_heart_link_datetime
	
	function search_for_keywords(oBtn) {
	   // oBtn.value = "Searching...";
	   // oBtn.disabled=true;
	   window.location.href='/search/'+URLencode(oBtn.parentNode.getElementsByTagName("INPUT")[0].value);
	   return false;
	}; // end function search_for_keywords 
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// The first stage of SRF HRTS had to be: -----------------------------------------------------------------------
//    It ain't as perfect as I want but as long as customers are satisfied enough to want more. -----------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------