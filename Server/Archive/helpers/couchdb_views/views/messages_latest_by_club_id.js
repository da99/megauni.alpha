// Creates key/value pairs like: 
//  [ [ 'club-vitamin-fanatics', '2010-01-01 01:01:20 ], 1 ]
//

function(doc) {

  if (doc.data_model == 'Message' && 
      doc.privacy == 'public' && 
      doc.target_ids )
    for(var i in doc.target_ids)
      if (doc.target_ids[i].indexOf('club-') == 0)
        emit( [doc.target_ids[i], doc.created_at], 1 );

};
