// var b = /\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.])(?:[^\s()<>]+|\([^\s()<>]+\))+(?:\([^\s()<>]+\)|[^`!()\[\]{};:'".,<>?«»“”‘’\s]))/
// var anchor_fy = function (str) {
//   return "<a href=\"" + str + ">" + str + "</a>";
// };
// var auto_link = function (piece){
//   var new_html = piece.html().replace(b, anchor_fy); 
//   return piece.html( new_html );
// };
// $(document).ready(function (){ 
//   auto_link($('div.message div.body'));    
// });
//
var url_regexp = /(https?:[^\s]+\.(jpg|gif|png|jpeg))/gi;

// GRAB_ALL_URLS
// LOOP_THROUGH EACH
// * load image
// * get dimensions
// * store dimensions
// * Marshalize object
// * Set to hidden input.
// *

var Form_Image_Dimension_Cacher = function(form_name, body_div_name ) {

  this.form = $('#' + form_name);
  this.body = (body_div_name) ? $(body_div_name) : $("#" + form_name + ' textarea[name=body]');

}; // Form_Image_Dimension_Cacher


var images = [];

var image_ready_counter = 0;
function image_ready(max){
  if(images.length == max)
    console.log(images.join("\n"));
};

function image_processor(i, val, max) {
  var img = new Image();
  img.onload = function(){
    images.push(val + ' ' + img.width + ' ' + img.height);
    image_ready(max);
  };
  img.src = val;
};

function grab_images(txt) {
  var matches = txt.match(url_regexp);
  var max = matches.length;
  $.each(matches, function(i,val){ image_processor(i,val,max) });
};

var img_srcs = ['http://farm5.static.flickr.com/4031/4642110880_5c18162b34.jpg',
'htTp://farm5.static.flickr.com/4025/4642110868_7e82baafe6.jpg',
'htTp://farm5.tatic.flickr.com/025/4642110868_7e82baafe6.jpg'];

var body = img_srcs.join(" --- text -- ");

