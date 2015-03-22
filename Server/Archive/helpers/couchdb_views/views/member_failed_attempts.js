// Creates keys like:
//   [ ['mem_id', '2010-01-04', 1], {:date=>, :member_id=>, ...} ]
//   [ ['mem_id', '2010-01-04', 2], {:date=>, :member_id=>, ...} ]
//   [ ['mem_id', '2010-01-04', 3], {:date=>, :member_id=>, ...} ]


function(doc) {
  if (doc.data_model == 'Member_Failed_Attempt')
    // emit( [doc.member_id, doc.date, doc.count], 1 );
    emit( [doc.member_id, doc.date], 1 );
};
