//
// Creates these indexes:
// [ ['pets',           '2007-04-03 11:11:02'], null ]
// [ ['hearts', 'pets', '2007-04-03 11:11:02'], null ]
// [ ['home',   'pets', '2007-04-03 11:11:02'], null ]
// [ ['health', 'pets', '2007-04-03 11:11:02'], null ]
//        

function(keys, values, rereduce) { 
  return sum(values);
};
