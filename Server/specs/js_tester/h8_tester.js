var current_h8_name = null;

function h8_name( new_name ) {
    current_h8_name = new_name + ' (id: ' + (Math.random() * 100).toString() + ')';
    return current_h8_name;
};


function h8_run( new_tests ) {
    var the_results = [];
    var funct_results = null;
    var page_reload_funct = null;
    for( var i = 0 ; i < new_tests.length ; i++ ){

        current_h8_name = null;
        funct_results = new_tests[i]();
        
        if(typeof(funct_results[1]) == "function") {
            // Check to make sure this is the last test.
            if( i != new_tests.length - 1 ){
                alert("ERROR: Page load test is not last test:  #" + i.toString() + ', last_test: ' + (new_tests.length - 1).toString() );
                return false;
            };        
            
            $.ajax({
                type: "POST",
                async: false,
                url:     "/h8_expect_page_load",  
                data:  { suite_id : h8_suite_id, expected : funct_results[0] , test_id : current_h8_name },          
                success : function(msg){
                },
                error: function(request){
                    alert("UNKNOWN ERROR when trying to save expected load page: \n" + request.status + " -- " + request.statusText );
                }  
            }); // $.ajax

            page_reload_funct  = funct_results[1];
        
        }; // if
        
        the_results.push( { 
            'name' : current_h8_name, 
            'id' : current_h8_name,
            'expected' : funct_results[0], 
            'actual' : funct_results[1] ,  
            'funct' : new_tests[i].toString() 
        });

    }; // for
    
    h8_save_results( the_results );
    if(page_reload_funct )
        page_reload_funct();
};



function h8_save_results( results ) {
    // Take results and turn them into a query string.
    var raw_results = "suite_id=" + h8_suite_id;
    for( var i = 0 ; i < results.length ; i++ ) {

        raw_results += "&the_results[][name]="+encodeURIComponent(results[i]['name'])  ; // the name
        raw_results += "&the_results[][expected]="+ encodeURIComponent(results[i]['expected'])   ; // expected val
        raw_results += "&the_results[][actual]="+ ( results[i]['actual'] ? encodeURIComponent(results[i]['actual']) : 'NOT+SET')  ;   // actual val
        raw_results += "&the_results[][funct]="+encodeURIComponent(results[i]['funct']) ;   // function code
        raw_results += "&the_results[][id]="+ encodeURIComponent(results[i]['id']) ;
        
        // Use '===' and not double '=' so you compare type and value.
        // Example: true == 1 evaluates to true. We don't want that. 
        // '===' takes care of this problem.
        if( results[i]['expected'] === results[i]['actual'] ) { 
            raw_results += "&the_results[][pass]=true" // Did it pass?
        };
    };

    // Send results
    $.ajax({ 
        type: "POST",
        async: false,
        url:     "/h8_save_results",  
        data: raw_results,
        success: function(msg) {
            var next_action = msg.split(':')[0];
            switch(next_action) {
                case 'NEXT TEST':
                  if(msg.split(':').length == 2 )
                    window.location.href = msg.split(':')[1];
                  else
                    alert("UNKNOWN MSG: \n"+ msg);
                  break;
                case 'NO MORE TESTS':
                  window.location.href = "/h8_results";
                  break;
                default:
                  alert("UNKNOWN ERROR: \n" + msg);
            } // switch
        }, 
        error: function(request) {
            alert("Error occurred when H8 tests \nresults were being saved:\n" + request.status + " -- " + request.statusText );
            console.log(request);
        }
     });
    
    // Process data that was sent back.
    return raw_results;
};



