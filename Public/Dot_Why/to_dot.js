
var DOT  = require('diet-dot');
var fs   = require('fs');
var temp_file = process.argv[2]
var html = fs.readFileSync(temp_file) + "";
var tmpl = DOT(html);
var data = {arr: process.argv, msg: "test"};


var new_file = 'Server/HTML_Templates/' + temp_file.split('/').pop().replace('.rb', '.js')
fs.writeFileSync(new_file, tmpl.toString() + "\nexports.render = anonymous;");

console.log(new_file)

