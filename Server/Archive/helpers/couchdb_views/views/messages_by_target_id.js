// Creates indexes:
//   [ 
//      ['club-hearts', '2010-01-01 10:19:10],
//      1
//   ]
//

function(doc) {
  if (doc.data_model == 'Message' && doc.target_ids) {
    for(var id in doc.target_ids)
      emit( [doc.target_ids[id], doc.created_at], 1 );
  };
};
