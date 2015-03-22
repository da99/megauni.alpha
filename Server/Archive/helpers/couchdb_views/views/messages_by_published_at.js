//
// Creates these indexes:
// [ '2007-04-03 11:11:02', null ]
// [ '2007-04-03 11:11:02', null ]
// [ '2007-04-03 11:11:02', null ]
// [ '2007-04-03 11:11:02', null ]
//        

function(doc) { 
  if (doc.data_model == 'Message' &&  doc.privacy == 'public'  ) {
    var pub_at = (doc.published_at || doc.created_at);
    if (pub_at)
      emit( pub_at, 1);
  };
};
