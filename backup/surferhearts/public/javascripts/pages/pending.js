// --------------------------------------------------------------------------------------------------------------
// Put all event observers here for page. -----------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
    Event.observe(window, 'load', apply_pending_page_rules)

// --------------------------------------------------------------------------------------------------------------
// Define variables for page here, including behaviour rules ----------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
    var pending_rules = {
        '#pending_dates li.datetime a': function (ele) { 
            ele.innerHTML = format_publish_date(ele.innerHTML); 
            ele.onclick = select_heart_link;
        },
        '#heart_links div.datetime': function (ele) { ele.innerHTML = format_publish_date(ele.title); }
    }; // end var pending_rules

// --------------------------------------------------------------------------------------------------------------
//  Put all functions for this page here ------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
function apply_pending_page_rules () {
	    Behaviour.list = new Array();
        Behaviour.register(pending_rules);
        Behaviour.apply();
}; // end function apply_pending_page_rules

function select_heart_link ( ) {
    new Effect.ScrollTo(this.rel);
    new Effect.Highlight(this.rel);
    return false
}; // end function select_heart_link
