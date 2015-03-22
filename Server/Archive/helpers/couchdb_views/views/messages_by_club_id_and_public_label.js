//
// Creates these indexes:
// [ [ 'club-vitamin-fanatics', 'pets', '2007-04-03 11:11:02' ] , 1  ]
//        

function(doc) { 
  if (doc.data_model == 'Message' && doc.privacy == 'public' && doc.public_labels) {
    for(var c in doc.target_ids) {
      if (doc.target_ids[c].indexOf('club-')==0)
        for(var t in doc.public_labels) {
          emit( [ doc.target_ids[c], doc.public_labels[t], (doc.published_at || doc.created_at)], 1);
        };
    };
  };
};
