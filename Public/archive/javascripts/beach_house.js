/* ************************************************************************************
        beach_house.js
        
        Copyright 2008 diego <deals@diegoalban.com>
        
        This program is free software; you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation; either version 2 of the License, or
        (at your option) any later version.
        
        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.
        
        You should have received a copy of the GNU General Public License
        along with this program; if not, write to the Free Software
        Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
        MA 02110-1301, USA.

************************************************************************************ */
     
     
/* 
 * Organize your html like this:
 * 
 * div.beach_house.empty_garden.empty_(class_name)#unique_id
 *     div.garden.empty_garden.ClassName
 *         div.empty_msg
 *             "Show if garden bed has 0 children or all children have class name 'stem_deleted'."
 *         div.garden_bed
 *             div.stem.stem_deleted#dom_id
 *                 div.leaf
 *                 div.knife
 *             div.stem.stem_deleted#dom_id
 *                 div.leaf
 *                 div.knife
 * 
 *         div.nursery#nursery_for_css_class_name
 *             div.error_msg
 *                 div.msg
 *             form
 * Class (object):
 *  ClassName : { 
 *      'compare'       : function(){},
 *      'afterGrab'   : function(html_from_response){},
 *      'afterReplace'   : function(){},
 *      'afterDestroy'  : function(html_from_response){}
 *  }
 */

var Soil = new Class({
    found_at   : 'beach_house',
    states     : [],
    $          : null,
    
    initialize : function(ele){
        // Set up names.
        this.js_name        = this.js_name || this.css_name.TallCamel();
        this.dot_css        = this.css_name.dot_it();
        this.english_name   = this.css_name.replace('_',' ');
        
        // Find the corresponding element to this object and attach itself to it.
        this.$  = $(ele).getTheBoss( this.dot_css , this.found_at.dot_it() );
        this.$.store( this.css_name , this); 
    },
    
    set_to : function(new_class, val) {
        // Reset classes.
        this.reset();
        
        if( !this.states.contains(new_class))
            return Swiss.reportError('Programmer eror: ' +new_class +
                    ' is not allowed as a state for ' + this.english_name+'.');
            
        // Set error is necessary.
        if(new_class==='error')
            this.setError(val || ('Unknown error for ' + this.english_name + '.') );
        
        // Update class of element.
        this.$.addClass(this.css_name + '_' + new_class);
        
        return this.$;
    },
    
    reset : function(){
        var original_ele    = this.$;
        var this_obj        = this;
        
        this.states.each(function(class_name){
            original_ele.removeClass(this_obj.css_name+'_'+class_name);
        });
        
        return this.$;
    },
    
    setError     : function(error){
        return this.grabError_$().getFirst('div.msg').set('text', Swiss.getErrorMsg(error));  
    },
    
    
    
    /*
     * Note: Returns the entire error block element.  To set the error message, 
     *  be sure to get it's child ('div.msg'). E.g:
     *  this.grabError_$().getFirst('div.msg').set('text', 'Some error.');
     */
    grabError_$ : function(){
        var blok = this.$.getFirst('div.error_msg');
        
        if(blok)
            return blok;
            
        // Create blok.
             blok = new Element('div', {'class' : 'error_msg'});
             blok.grab( new Element('h6', {'text' : 'Errors:'}));
             blok.grab( new Element('div', {'class' : 'msg'}));
         
         // Add blok.
             this.$.grab( blok , 'top' );
             
        return blok;
    } // end grabErrorBlock_

   
}); // end Soil

var BeachHouse = new Class({
    
    Extends     : Soil,
    css_name   : 'beach_house'
    
}); // end BeachHouse

var Garden = new Class({
    
    Extends     : Soil,
    css_name    : 'garden',
    
    reset : function(){
        this.resize();
        return this.parent();
    }, // end reset
    
    resize : function() {

        (this.$.getGardenBed().is_empty())
            ? this.$.getBeachHouse().$.addClass('empty_garden')
            : this.$.getBeachHouse().$.removeClass('empty_garden'); 
        
        return this;
    }, // end resize
    
    grab_$ : function(new_stem, flash_it){ 
        var this_garden         = this;
        var garden_bed          = this.$.getGardenBed();
        
        // Insert stem.
        garden_bed.grab_$(new_stem)
        
        // Resize collection.
        this.resize( );
        
        // Flash it.
        if(flash_it===null || flash_it)
            new_stem.flash_it();
            
        return new_stem;
    }, // end grab
    
    getModel : function(use_default_if_not_found){
        
        if(this.stemModel)
           return  this.stemModel;
        
        var is_class            = function(class_name){ return class_name.capitalize() === class_name; };
        var css_class_names     = this.$.get('class').split(' ').filter( is_class );
        
        if(css_class_names.length===0 ) 
            return (use_default_if_not_found && this.getDefaultModel()) || null; 
        
        if(!window[css_class_names[0]]){
            Swiss.reportError("Error in Garden::getModel: Programmer did not define stem model: " + css_class_names[0]);
            return (use_default_if_not_found && this.getDefaultModel()) || null;   
        };
            
        this.stemModel               = window[css_class_names[0]];
        this.stemModel.js_name       = this.stemModel.js_name         || css_class_names[0];
        this.stemModel.css_name      = this.stemModel.css_name        || this.stemModel.js_name.flat_camel();
        this.stemModel.english_name  = this.stemModel.english_name    || this.stemModel.css_name.to_english();
        
        return this.stemModel;
   }, // end getModel
   
    getDefaultModel : function(){
        return {
            js_name : 'UnknownModel',
            css_name : 'unknown_model',
            english_name : 'unknown model'    
        };
    }
    
    
}); // end Garden

var GardenBed = new Class({
    Extends     : Soil,
    css_name    : 'garden_bed',
    found_at    : 'garden',
    
    is_empty : function(){
        var is_alive       = function(ele){return !ele.hasClass('stem_deleted'); };
        var alive_stems    = this.$.getChildren('.stem').filter( is_alive );  
        
        return  alive_stems.length===0;
    },
    
    
    grab_$  : function(new_ele){
        
        var inserted    = false;
        var i           = 0;
        var blok        = this.$;
        var sort_by     = this.$.getGarden().getModel(true).compare || 'top';
            
        // Handle simple cases of 'top' and 'bottom'
        if( $type(sort_by) === 'string') 
            
            inserted = blok.grab(new_ele, sort_by);
            
        else{ // Go through each Child and insert if sort_by agrees with Child.
            var childs = blok.getChildren();
            
            while(!inserted && i < childs.length ){
                
                if( sort_by(new_ele, childs[i]) ) 
                    inserted = new_ele.inject( childs[i], 'before'); 
                    
                i++;
            }; 
        };
        
        // Insert at bottom if 'sort_by' kept returning false.
        if(!inserted)
            inserted = blok.grab(new_ele, 'bottom');
            
        return this.$;

    } // end grab
    
    
}); // end GardenBed

var Stem = new Class({
    
    Extends     : Soil,
    
    css_name    : 'stem',
    found_at    : 'stem',
    
    states : [
        'loading', 
        'editing', 
        'cancelled_edit', 
        'updating' ,
        'updated' , 
        'deleted' ,
        'error'
    ],
    
    hasKnife : function() {
        return (this.$.getElement('.knife')) ? true :false;
    },
    
    getKnife  : function(link_ele){ /* getKnife... as in HTTP GET an editing form for stem */

        var stem = this;
        
        // If it already has a knife, then show it and return.
        if( stem.hasKnife() ){
            stem.set_to( 'editing');
            return false;
        };
        
        // Set to loading.
        stem.set_to('loading');
        
        // Create a new request. 
        var opts = {
            method : 'get' , 
            url: $(link_ele).get('href'), 
            evalScripts : false, 
            evalResponse : false,
            onSuccess : function(html){     
                            var html_eles   = new Elements(html);
                            var new_form        = (!html_eles || html_eles.length===0) ? null : html_eles[0];
                            
                            // Display error if necessary.
                            if(!new_form || (!new_form.hasClass('knife') && !new_form.hasClass('error_msg')))
                                return stem.set_to('error', 'Programmer error. Contact support and tell them to put in a form thingy to edit a ' + stem.$.getGarden().getModel(true).english_name + '.');
                            
                            if(new_form.hasClass('error_msg'))
                                return stem.set_to('error', new_form.get('text'));
                            
                            // Grab knife for stem.
                            if(new_form.hasClass('knife'))
                                return stem.grabKnife_$(new_form);
                             
                            
            }, 
            onFailure   : function(request){        stem.set_to( 'error', { 'request' : request }) },
            onException : function(header, val){    stem.set_to( 'error', { 'header'  : header, 'val' : val }) }
        };
        
        var knife_request = new Request.HTML(opts);

        try {
            knife_request.send();
        } catch (e) {
            stem.set_to('error', {'exception' : e});
        };
        
        return false;

    }, // end getKnife
    
    grabKnife_$ : function(new_form){
        this.$.grab( new_form, 'bottom' );
        this.set_to( 'editing' );   
        return this.$;
    },
    
    unstore_$ : function(){
        var old_ele = this.$;
        
        if(!old_ele)
            return null;
        
        old_ele.store(this.css_name, null);
        this.$ = null;
        
        return null;
    }, // end unstore_$

    replace_$ : function(new_ele, flash_it){
        
        var old_ele = this.$;
        
        // Disconnect from element..
        this.unstore_$();
        
        // Replace it in the DOM.
        new_ele.replaces(old_ele);
        old_ele.destroy();
        
        // Store new $.
        new_ele.store(this.css_name, this);
        this.$ = new_ele;  
        
        // Flash it if necessary.
        if( flash_it === null || flash_it)
            this.$.flash_it();
        
        return this.$;
    }, // replace_$
    
    destroy_$ : function( undo_delete_ele ){
        
        // If undo is available for this element,
        //   then treat it as an element replace.
        if(undo_delete_ele) {
            if($(undo_delete_ele) && $(undo_delete_ele).hasClass('undo_delete')){
                this.replace_$(undo_delete_ele).getGarden().reset();
                return null;
            };
            return this.set_to('error', 'Programmer error. Contact support and they will fix it for you.');
        };

        // Grab current element.
        var old_ele = this.$;
        var garden = old_ele.getGarden();
        
        // Make sure element does not hold this object
        //   any longer.
        this.unstore_$();

        // Remove it from the DOM.
        old_ele.destroy();
       
        // Reset garden.
        garden.reset();
        
        return null;
    } // end delete_$
  
}); // end Stem

var Leaf = new Class({
    
    Extends     : Soil,
    css_name   : 'leaf',
    found_at    : 'stem'
    
}); // end Leaf

var Knife = new Class({

    Extends     : Soil,
    css_name    : 'knife',
    found_at    : 'stem',
    states      : [ 'loading', 'error'],
    
    grabError_$ : function(){
        return this.$.getStem().grabError_$();    
    },
    
    postReplace : function() { // POST new values for stem.
        var knife       = this;
        var knife_form  = this.$.getElement('form');
        var garden = this.$.getGarden();
        
        this.set_to('loading');
        
        if( !this.previous_request ) {
            var opts = {
                method          : 'post' , 
                url             : knife_form.get('action'), 
                evalScripts     : false, 
                evalResponse    : false,
                onSuccess       : function(html){           
                                var html_eles = new Elements(html);
                                var updated_stem = (!html_eles || html_eles.length === 0) ? null : html_eles[0];
                                
                                // Set error if no elements found.
                                if(!updated_stem)
                                    return knife.set_to('error', 'Programmer error. Contact support and tell them you can\'t update: ' + knife.$.getGarden().getModel(true).english_name );
                                
                                // Replace stem.
                                if(updated_stem.hasClass('stem')) {

                                    knife.replace_$(updated_stem); 

                                    // Send original result to model method if it exists.
                                    if(  garden.getModel(true).afterReplace )
                                         garden.getModel().afterReplace( html ); 

                                         
                                } else {
                                    if(updated_stem.hasClass('error_msg'))
                                        knife.set_to('error', updated_stem.get('text'));
                                    else
                                        knife.set_to('error', 'The programmer made a mistake on the template. Contact support to fix this.');
                                };
                                

                }, 
                onFailure   : function(request){       knife.set_to('error', {'request':request});                 },
                onException : function(header, val){   knife.set_to('error', {'header': header, 'val' : val });    }
            };
            
            this.previous_request = new Request.HTML(opts);
        };
        
        try {
            this.previous_request.send( {data : knife_form.toQueryString()} );
        } catch (e) {
            knife.set_to('error', {'exception':e});
        };
                
        return false;
    } , // end postReplace
    
    replace_$ : function(updated_stem){ 
        return this.$.getStem().replace_$( updated_stem );    
    },
    
    postDestroy : function(ele){ // send a HTTP POST to "delete entity"/"destroy element".
        var knife       = ele.getKnife();
        var knife_form  = knife.$.getElement('form');
        var garden      = knife.$.getGarden();
        
        knife.set_to('loading');
        if( !knife.previous_delete_request ) {
            var opts = {
                method      : 'post',
                url         : knife_form.get('action').replace('update', 'delete'),
                evalScripts     : false,
                evalResponse    : false,
                onSuccess : function(html){  
                    
                    
                    var html_elements   = new Elements(html);
                    var new_stem        = (!html_elements || html_elements.length === 0) ? null : html_elements[0];
                    
                    // Display template error.
                    if( !new_stem ){
                        return knife.set_to('error', "Empty results for destroying: " + knife.$.getGarden().getModel(true).english_name );
                         
                    };

                    // Destroy knife.
                    if(new_stem.hasClass('success_msg') || new_stem.hasClass('undo_delete')) {
                        
                        if(new_stem.hasClass('success_msg'))
                            knife.destroy_$();
                        else if( new_stem.hasClass('undo_delete') )
                            knife.destroy_$(new_stem);
                        
                        // Past it on to the Model class.

                        if( garden.getModel(true).afterDestroy )
                            garden.getModel().afterDestroy(html);
                    } else {
                        if(new_stem.hasClass('error_msg'))
                            knife.set_to('error', new_stem.get('text'));    
                        else
                            knife.set_to('error', 'Unknown programmer error.  Contact support and tell them they made a small boo-boo.');
                    };
                    
                },
                onFailure : function(request){       knife.set_to('error', {'request' : request });               },
                onException : function(header, val){ knife.set_to('error', {'header' : header, 'val' : val });    }
            };
        };
        
        try {

            knife.previous_delete_request = new Request.HTML(opts);
            knife.previous_delete_request.send({data : knife_form.toQueryString()});

        } catch (e) {
            knife.set_to('error', {'exception' : e} );    
        };
        
        
    },
    
    destroy_$ : function(new_stem){
        var knife           = this;
        var garden          = knife.$.getGarden();
        
        if( new_stem &&  $(new_stem) && !new_stem.hasClass('undo_delete')  ) {
            knife.set_to('error',  'Programmer error: Undo delete element not properly defined.' ); 
            return null;
        };
                
        knife.$.getStem().destroy_$(new_stem);
            
        // Pass it to a custom handler if defined.
        if( garden.getModel(true).afterDestroy )
            garden.getModel().afterDestroy(new_stem);
        
        return null;              
    }

    
}); // end Knife

var Nursery = new Class({ 

    Extends     : Soil,
    css_name    : 'nursery',
    found_at    : 'garden',
    states      : [ 'loading' , 'error' ], 
    
    reset : function(reset_form){
        this.parent();
         
        if( reset_form )
            this.$.getElement('form').reset();
            
        return this.$;
    }, // end reset
    
    grab_$ : function( new_stem ){  
                
        // Insert new stem.
        this.$.getGarden().grab_$( new_stem );
        this.reset(true ); // reset nursery AND form.
        
        return this.$; 
    
    }, // end onSuccess
    
    postGrab : function(){ // send an HTTP POST to create new stem.
        
        var nursery         = this; 
        var nursery_form    = this.$.getFirst('form');   
        var garden          = nursery.$.getGarden();     
        
        
        nursery.set_to('loading' );
        
        if(!this.previous_request) {
            
            var opts = {
                method  : 'post' , 
                url     : nursery_form.get('action'), 
                evalScripts     : false, 
                evalResponse    : false,
                onSuccess       : function(html){ 
                    
                        var html_eles = new Elements(html);
                        var new_stem  = (!html_eles || html_eles.length === 0) ? null : html_eles[0] ;
                        
                        
                        // Display template error msg.
                        if(!new_stem || !$(new_stem) || (!new_stem.hasClass('stem') && !new_stem.hasClass('error_msg')) ) 
                            return nursery.set_to( 'error', "Programmer error: template is invalid." );
                        
                        // Display error message.
                        if( new_stem.hasClass('error_msg') ) 
                            return nursery.set_to( 'error', new_stem.get('text') );
                        
                        // Insert new stem.
                        if( new_stem.hasClass('stem') ){
                            nursery.grab_$(new_stem);
                            // If a method has been defined, then pass on original results.
                            if(         garden.getModel(true).afterGrab       ) 
                                return  garden.getModel().afterGrab( html );
                        };

                    
                }, 
                onFailure   : function(request){        nursery.set_to( 'error', {'request' : request} );  },
                onException : function(header, val){    nursery.set_to( 'error', {'header' : header, 'val' : val }); }
            };
            
            this.previous_request = new Request.HTML(opts);
        };
        
        try {
            this.previous_request.send({data : nursery_form.toQueryString() });
        } catch (e) { 
            nursery.set_to( 'error', {'exception':e} );
        };
        
        return false;
    
    } // end postGrab
    

    
}); // end Nursery



var createBeachHouseButler = function(class_name){ 
    
    return function(){ 
        var target_ele = this.retrieve( class_name.flat_camel() );
        if( target_ele  )
            return target_ele;
        
        target_ele = this.getTheBoss( class_name.flat_camel().dot_it() ,  (window[class_name].prototype.found_at && window[class_name].prototype.found_at.dot_it()) ) 
        
        return target_ele.retrieve( class_name.flat_camel() ) || new window[class_name](this); 
    };
    
};

// Add 'getBeachHouse', 'getGarden', etc., to Element.
var bh = {};
['BeachHouse', 'Garden', 'GardenBed', 'Stem', 'Leaf', 'Knife', 'Nursery'].each(function(class_name){
    bh['get'+class_name] = createBeachHouseButler(class_name)
});

Element.implement( bh );


