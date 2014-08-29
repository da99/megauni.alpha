
var dot = require('diet-dot');


var fs = require('fs');
var template = fs.readFileSync("./template.html") + "";

var c = dot(template);
console.log(c({arr: process.argv, msg: process.argv[2] || "unknown" }));

