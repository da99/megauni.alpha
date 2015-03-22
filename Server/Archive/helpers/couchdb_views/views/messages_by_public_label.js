//
// Creates these indexes:
// [ 'pets',   '2007-04-03 11:11:02'  ]
// [ 'hearts', '2007-04-03 11:11:02'  ]
// [ 'home',   '2007-04-03 11:11:02'  ]
// [ 'health', '2007-04-03 11:11:02'  ]
//        

function(doc) { 
  if (doc.data_model == 'Message' && doc.privacy == 'public' && doc.public_labels)
    for(var t in doc.public_labels) 
      emit( doc.public_labels[t], (doc.published_at || doc.created_at) );
};
