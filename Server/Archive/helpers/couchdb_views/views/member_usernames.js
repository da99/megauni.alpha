// Creates keys like:
//  [ 'da01',  'member-1']
//  [ 'da01tv', 'member-1']
//  [ 'my_username', 'member-300']

function(doc) {
  if (doc.data_model == 'Member' && doc.lives)
    for( var i in doc.lives )
      emit( doc.lives[i].username, doc._id );
};
