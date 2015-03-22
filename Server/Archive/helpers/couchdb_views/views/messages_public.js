// Creates keys like: 
//  [ '2010-01-02 01:11:23', 1 ]
//

function(doc) {

  if (doc.data_model == 'Message' && doc.privacy == 'public' && doc.created_at && doc.created_at > '2010-01-01 00:00:00')
    emit( doc.created_at, 1 );

};
