/*
 *  Copyright 2012-2013 (c) Pierre Duquesne <stackp@online.fr>
 *  Licensed under the New BSD License.
 *  https://github.com/stackp/promisejs
 */
(function(a){function b(){this._callbacks=[];}b.prototype.then=function(a,c){var d;if(this._isdone)d=a.apply(c,this.result);else{d=new b();this._callbacks.push(function(){var b=a.apply(c,arguments);if(b&&typeof b.then==='function')b.then(d.done,d);});}return d;};b.prototype.done=function(){this.result=arguments;this._isdone=true;for(var a=0;a<this._callbacks.length;a++)this._callbacks[a].apply(null,arguments);this._callbacks=[];};function c(a){var c=new b();var d=a.length;var e=0;var f=[];function g(a){return function(){e+=1;f[a]=Array.prototype.slice.call(arguments);if(e===d)c.done(f);};}for(var h=0;h<d;h++)a[h].then(g(h));return c;}function d(a,c){var e=new b();if(a.length===0)e.done.apply(e,c);else a[0].apply(null,c).then(function(){a.splice(0,1);d(a,arguments).then(function(){e.done.apply(e,arguments);});});return e;}function e(a){var b="";if(typeof a==="string")b=a;else{var c=encodeURIComponent;for(var d in a)if(a.hasOwnProperty(d))b+='&'+c(d)+'='+c(a[d]);}return b;}function f(){var a;if(window.XMLHttpRequest)a=new XMLHttpRequest();else if(window.ActiveXObject)try{a=new ActiveXObject("Msxml2.XMLHTTP");}catch(b){a=new ActiveXObject("Microsoft.XMLHTTP");}return a;}function g(c,d,g,h){var i=new b();var j,k;g=g||{};h=h||{};try{j=f();}catch(l){i.done(-1,"");return i;}k=e(g);if(c==='GET'&&k){d+='?'+k;k=null;}j.open(c,d);j.setRequestHeader('Content-type','application/x-www-form-urlencoded');for(var m in h)if(h.hasOwnProperty(m))j.setRequestHeader(m,h[m]);function n(){j.abort();i.done(a.promise.ETIMEOUT,"",j);}var o=a.promise.ajaxTimeout;if(o)var p=setTimeout(n,o);j.onreadystatechange=function(){if(o)clearTimeout(p);if(j.readyState===4){var a=(!j.status||(j.status<200||j.status>=300)&&j.status!==304);i.done(a,j.responseText,j);}};j.send(k);return i;}function h(a){return function(b,c,d){return g(a,b,c,d);};}var i={Promise:b,join:c,chain:d,ajax:g,get:h('GET'),post:h('POST'),put:h('PUT'),del:h('DELETE'),ENOXHR:1,ETIMEOUT:2,ajaxTimeout:0};if(typeof define==='function'&&define.amd)define(function(){return i;});else a.promise=i;})(this);