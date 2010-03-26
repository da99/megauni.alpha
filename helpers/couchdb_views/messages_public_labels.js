//
// Creates these indexes:
// [ 'pets',   1 ]
// [ 'hearts', 1 ]
// [ 'home',   1 ]
// [ 'health', 1 ]
//        

function(doc) { 
  if (doc.data_model == 'Message' && doc.message_model == 'news' && doc.public_labels)
    for(var t in doc.public_labels)
      emit( t, 1 );
};

