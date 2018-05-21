var Newspaper = {

  __toggle_it__ : function(link_ele, phrase) {
            var link = $(link_ele);
            var target = link.parents('div.field');
            link.parents('span.editable').html('<span class="loading">' + phrase + '</span>');
            
            return Swiss.anchor.submit(link, target);   
  }, // __toggle_it__

  toggle_privacy : function(link_ele){
    return Newspaper.__toggle_it__(link_ele, 'Loading...');
  }, // end toggle_privacy

  trash : function(link_ele){    
    return Newspaper.__toggle_it__(link_ele, 'Deleting...');
   }, // end trash

  untrash : function(link_ele){
    return Newspaper.__toggle_it__(link_ele, 'Recycling...');
   } // end untrash

}; // Newspaper



// Show Page.
Swiss.loading.page_finished();
