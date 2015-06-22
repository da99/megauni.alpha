var BusyForm = new Class({

  states : $A(['error', 'loading', 'success']),
  
  ifSuccessMsg : function(ele_coll, eles, responseText){
    eles[0].replaces(this.folder.getElement('FORM'));
  },
  
  ifErrorMsg : function(node_list, eles, responseText){
    this.set('error', eles[0].get('html') )
  },
  
  initialize : function(ele){
    this.form = ele.getElement('form');
    this.folder = ele;
    if(Swiss.browser.on_dev && window.console)
      console.log('Created a BusyForm.');
  },
  
  'set' : function(){
  
    prop = arguments[0];
    new_val = arguments[1];
    
    switch(prop){
    
      case 'state':
          this.reset();
          if( !this.states.contains( new_val ) )
            Swiss.reportError('"'  +new_val + '" is not a valid state for BusyForms.');
          this.folder.addClass('busy_form_'+new_val);
        break;
      
      case 'error': // Display an error in the folder.
        this.folder.getElement('div.error_msg div.msg').set('html', new_val)
        this.set('state', 'error')
        break;
      
      case 'ifSuccessMsg': // If the HTML request response includes '<div class="success_msg"'
        this.ifSuccessMsg = new_val;
        break;
        
      case 'ifErrorMsg': // If the HTML request response includes '<div class="success_msg"'
        this.ifErrorMsg = new_val;
        break;
        
      case 'menu': 
        // Go through a SELECT menu object in the form and select
        // the first OPTION that returns true when from the given select function.
        // All other OPTION elements are de-selected. 
        var target_menu = this.form.getElement('select[name=' + new_val+']');
        var select_func = arguments[2];
        if(!target_menu)
          Swiss.reportError('Menu, ' + new_val + ', not found for BusyForm.');
        
        var selected_opt = null;
        
        target_menu.getElements('option').each(function(ele){
            (!selected_opt && select_func(ele)) 
                ? (selected_opt = ele).setProperty('selected', 'selected')
                : ele.removeProperty('selected');
        });
        
        break;


      default:
        Swiss.reportError('This BusyForm does not understand this setting: ' + prop);
    };
    return this;
  },
  
  'reset' :  function(){ 
    var this_folder= this.folder;
    this.states.each(function(folder_state){
      this_folder.removeClass('busy_form_'+folder_state)
    });
    return this;
  },
  
  'submit' : function(){
  
    this.set('state', 'loading');
    var prevReq= this.folder.retrieve('prevRequest');
    var this_folder = this.folder;
    var this_busy_form = this;
    
    // Create Request.HTML object if does not exist.
    if(!prevReq){
    
      // Set up options.
      var opts = this.form.get('send').options;
      opts.evalScripts = false;
      opts.evalResponse = false;
      
      opts.onFailure      = function(){ this_busy_form.set('error', 'Computer found an error. Try again later when it is fixed.'); };
      
      opts.onException = function(header, val){  this_busy_form.set('error', 'Request.HTML exception: header: ' + header + ', value: ' + val);  };
      
      opts.onSuccess = function(node_list, eles, responseText){
        var msg = eles[0];
        switch(msg.get('class')){
          case 'success_msg':
              this_busy_form.ifSuccessMsg(node_list, eles, responseText);
            break;
          case 'error_msg':
          default:
            this_busy_form.ifErrorMsg(node_list, eles, responseText);
        }; // end switch
      };
      
      // Create new Request.HTML and store it.
      this_folder.store('prevRequest', (new Request.HTML(opts)) );
      
      // Retrieve it.
      prevReq = this_folder.retrieve('prevRequest');
      
    };
    
    prevReq.send();
    return this;
  }
});

// Add 'getBusyForm' method to Element.
Element.implement({
  'getBusyForm' : function(){
    var folder = this.getTheBoss('div.busy_form');
    var bf = folder.retrieve('busy_form');
    if(!bf)
      this.store('busy_form', (bf = new BusyForm(folder)) );
    return bf;
  }
});
