var Article = {};

Article.create = function(link_ele){
  // alert( $(link_ele).parents('FORM').serialize() );
  // return false;
  Swiss.form.submit(link_ele);
}; // Article.create

// Show Page.
Swiss.loading.page_finished();
