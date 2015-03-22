// Creates indexes:
//   [ 
//      'club-hearts',
//      1
//   ]
//

function(doc) {
  if (doc.data_model == 'Message' && doc.target_ids) {
    for(var id in doc.target_ids)
      if (doc.target_ids[id].indexOf('club-') == 0 )
        emit( doc.target_ids[id], 1 );
  };
};
