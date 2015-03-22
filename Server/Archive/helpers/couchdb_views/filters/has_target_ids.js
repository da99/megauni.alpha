
function(doc, req) {

  var target_ids = req.query.target_ids.split(',')

  var finder_func= function(val){ 
    return target_ids.indexOf(val) > -1;
  };
  
  var process_message = (doc.data_model == 'Message' &&
                         doc.privacy == 'public' &&
                         !doc.updated_at &&
                         doc.target_ids);
  
  var has_target = process_message && doc.target_ids.some(finder_func);
  
  return has_target;

};
