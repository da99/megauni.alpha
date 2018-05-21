// ==========================================================
// Check lists.
// ==========================================================

var CheckList = {

  page_finished : function(){
  
  }
}; // end CheckList

CheckList.update = {
    submit : function(form){
      Swiss.form.submit( form );
    }

}; // end CheckList.update


// ==========================================================
// Check list items.
// ==========================================================

var CheckListItem = {

  page_finished : function(){
    CheckListItem.quantities_changed();
  },
  
  
  /*
    Meant to be called by other methods, such as :newly_created.
  */
  quantities_changed : function(form, results){
    var all_items     = $('#items > *');
    var empty         = all_items.length < 1;
    var substantial   = all_items.length > 1;
    var empty_msg     = $('#create_item p.empty_msg:first');
    var clone_tab     = $('#check_list_tabs li a[@href="#clones"]').parents('LI');
    var clones        = $('#clones');
    var empty_action  = (empty) ? 'show' : 'hide';
    var substantial_action = (substantial) ? 'show' : 'hide';
    
    empty_msg[empty_action]();
    
    clone_tab[substantial_action]();
    clones[substantial_action]();   
    
    // Update item summary.
    $('#check_list div.item_summary:first').text(results.vals.find('div.item_summary').text());

  },
  
  create : function( link_ele  ){
    return Swiss.form.submit( $(link_ele).parents('FORM'), { 'success_msg' : CheckListItem.newly_created}  );
  },   // =============================
  
  edit : function( link_ele ) {
    return Swiss.form.submit( $(link_ele).parents('FORM'), {'success_msg' : CheckListItem.editing } );
  }, // ============================
  
  update : function( link_ele ){
    return Swiss.form.submit( $(link_ele).parents('FORM'), { 'success_msg' : CheckListItem.newly_updated} );
  }, // ============================
  
  trash : function( link_ele ){
    return Swiss.form.submit( $(link_ele).parents('FORM'), { 'success_msg' : CheckListItem.newly_trashed} );
  }, // ============================ 
  
  untrash : function( link_ele ){
    return Swiss.form.submit( $(link_ele).parents('FORM'), { 'success_msg' : CheckListItem.newly_untrashed} );
  }, // ============================ 
  
  newly_created : function( form, results ){
    // First, reset the form.
    Swiss.form.reset(form, true);
    
    // Insert the item.
    $('#items').append(results.vals.find('div.item:first'))
    
    // Update other properties
    CheckListItem.quantities_changed(form, results);
  }, // =======================
  
  editing : function( form, results, opts ) {
    // Insert form before item.
    results.vals.find('form:first').insertBefore( opts['item'] );
    
    // Hide item.
    opts['item'].hide();
    
  }, // ============================
  
  newly_updated : function( form, results ) {
    // Replace old item.
    $(form).next().replaceWith(results.vals.find('div.item:first'));
    
    // Get rid of the form.
    $(form).remove();
        
    // Update other properties.
    CheckListItem.quantities_changed(form,results);
  },
  
  newly_trashed : function(form,results){
    // Replace old item.
    $(form).next().replaceWith(results.vals.find('div.item:first'));
    
    // Get rid of the form.
    $(form).remove();
        
    // Update other properties.
    CheckListItem.quantities_changed(form,results);
  }, // ============================
  
  newly_untrashed : function(form,results){
    // Replace old item.
    $(form).next().replaceWith(results.vals.find('div.item:first'));
    
    // Get rid of the form.
    $(form).remove();
        
    // Update other properties.
    CheckListItem.quantities_changed(form,results);    
  } // ============================
  
}; // CheckListItem


// ==========================================================
// ==========================================================
// After page loads.
// ==========================================================
// ==========================================================

CheckList.page_finished();

CheckListItem.page_finished();


// Finally, show the page.
Swiss.loading.page_finished();

// ==========================================================
