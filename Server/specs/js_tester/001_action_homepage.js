 // PATH: /
// NAME: Homepage 

h8_tests.push(    function() {
    h8_name("See if CSS files are loaded.");    
    
    
    return [ "test", "test" ];
});


h8_tests.push( function(){
    h8_name("See if 1 == 1");
    return [ 1, 1 ];
} );

h8_tests.push(
    function(){
        h8_name("See if /about page loads from /");
        return [ "/about_us", function(){ 
        
            window.location.href = "/about"
        
        } ];
    }
);



