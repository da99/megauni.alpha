// ==========================================================
// Newspapers
// ==========================================================
var Newspaper = { 

  after_create : function(form, eles, opts){
    $('#newspaper_list').prepend( eles.children('div.newspaper') )
  },

  create : function(link){        
    Swiss.form.submit( link , {'success_msg' : Newspaper.after_create} );
  }
  
}; // Newspaper

// ==========================================================
// Member
// ==========================================================
var Member = {
  update : function(link){
            Swiss.form.submit( link );
           }
}; // Member


// ==========================================================
// ==========================================================
//  After the page loads.
// ==========================================================
// ==========================================================


// Show Page.
Swiss.loading.page_finished();
// ==========================================================















