//
// Creates these indexes:
// [ 'pets',   1 ]
// [ 'hearts', 1 ]
// [ 'home',   1 ]
// [ 'health', 1 ]
//        

function(doc) { 
  if (doc.data_model == 'Message' && doc.privacy == 'public' && doc.public_labels)
    for(var t in doc.public_labels)
      emit( doc.public_labels[t], 1 );
};

