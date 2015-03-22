// Creates indexes:
//   [ 
//      [ 'club-hearts', '2005-10-10 03:05:24' ],
//      1
//   ]
//

function(doc) {
  if (doc.data_model == 'Message' && doc.target_ids) {
    for(var id in doc.target_ids)
      if (doc.target_ids[id].indexOf('club-') == 0 )
        emit( [doc.target_ids[id], (doc.published_at || doc.created_at)], 1 );
  };
};
