// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults




function $$$(id_or_css, options) {
	options = options ? options : {};
	var ele = $(id_or_css);
	ele = (!ele) ? ( (ele = $$(id_or_css)) ?  ele.first() : ele ) : ele;
	if(!ele){
		var coll = $$(id_or_css);
		ele = ( coll.length == 0) ? null : coll.first();
	};
	if( ele && options.parseAnchorName)
		ele = (ele.getAttribute('href') && ele.getAttribute('href') !='') ? $$$( parseAnchorName(ele.getAttribute('href')) ) : ele;

	return ele;
};


var Tab = {
	/*
	 * Method: select
	 * Parameters:
	 * 	target_tab - Element of id of element;
	 *  options    - Optional set of parameters. Currently, only :reuse is being used.
	 */
	select : function() {
		
		var target_tab = ( $(arguments[0]).up('li') &&  $(arguments[0]).up('li').id ) || 
				 $(arguments[0])  ;
		var options    = Object.extend( { reuse : true} , (arguments[1] ? arguments[1] : {}) );
		
		if(!$(target_tab))
			return;
		
		$(target_tab).blur();
		if($(target_tab).hasClassName('selected'))
			return false;
		var tabs = $(target_tab).up('div.tabs');
		var tabs_body = $(tabs.id+'_body');
		// De-select all tabs.
		tabs.select('li').each( function(ele) { ele.removeClassName('selected'); });
		// Select targeted tab.
		$(target_tab).addClassName('selected');
		
		// De-select all tab bodies.
		tabs_body.select('div.tab_body').each( function(ele) { ele.removeClassName('selected'); });
		// Select targeted tab.
		$( $(target_tab).id.replace(/show_/, '') + '_body' ).addClassName('selected');
		
		// Save selection to a cookie for re-use.
		( !$(target_tab).id.empty() && options.reuse && $(target_tab).id != 'show_settings') 
			? Cookie.set( 'page-'+window.location.pathname, $(target_tab).id , 1 ) 
			: Cookie.erase( 'page-'+window.location.pathname );
		
	},
	
	
	select_saved_tab : function(){
		// Users the last saved tab id, if exists, from Tab#select
		if( Cookie.get( 'page-'+window.location.pathname ) )
			Tab.select( Cookie.get( 'page-'+window.location.pathname ) );
	}
}; // end Tab



// ------------------------------------------------------------
Ajax.Request = null; 

if(  window.location.hostname ==  'localhost' ) {

};


