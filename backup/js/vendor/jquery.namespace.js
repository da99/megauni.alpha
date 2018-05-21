/* Copyright (c) 2008 Gilberto Saraiva (saraivagilberto@gmail.com || http://gsaraiva.projects.pro.br)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 * Version: 2008.0.1.1 -
 * Under development and testing
 *
 * Requires: jQuery 1.2+
 *
 * Support/Site: http://gsaraiva.projects.pro.br/openprj/?page=jquerynamespace
 */

(function( jQuery ){
  jQuery.fn.extend({ curReturn: null, jQueryInit: jQuery.fn.init });

  jQuery.fn.extend({
  	init: function( selector, context ) {
      jQuery.fn.curReturn = new jQuery.fn.jQueryInit(selector, context);
      return jQuery.fn.curReturn;
  	}
  });

  jQuery.extend({
    namespaceData: {},
    namespaceExtend: function(NameSpaces){
      if(eval(NameSpaces) != undefined){ $.extend(eval(NameSpaces), {}); }else{ eval(NameSpaces + " = {};"); }
    },
    namespace: function(namespaces, objects){
      if(typeof objects == "function"){
        if(namespaces.match(".")){
          nss = namespaces.split(".");
          snss = "";
          for(var i = 0; i < nss.length; i++){
            snss += "['" + nss[i] + "']";

            jQuery.namespaceExtend("jQuery.namespaceData" + snss);
            jQuery.namespaceExtend("jQuery.fn" + snss);
          }
          eval("jQuery.namespaceData" + snss + " = objects;");
          eval("jQuery.fn" + snss + " = " +
            "function(){ return eval(\"jQuery.namespaceData" + snss + "(jQuery.fn.curReturn)\"); }");
        }else{
          jQuery.extend({
            namespaces: function(){
              return objects(jQuery.fn.curReturn);
            }
          });
        }
      }else{
        for(var space in objects){
          jQuery.namespace(namespaces + "." + space, objects[space]);
        };
      }
    }
  });
})( jQuery );