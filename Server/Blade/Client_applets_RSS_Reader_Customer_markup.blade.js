function anonymous(locals,cb,__){with(__=__||[],__.r=__.r||blade.Runtime,__.func||(__.func={},__.blocks={},__.chunk={}),__.locals=locals||{},__.filename="/home/da/DEV/apps/okdoki/Client/applets/RSS_Reader_Customer/markup.blade",__.locals)__.r.blockMod("a","Creates",__,function(s){s.push('<div class="box"><div class="setting"><a href="#show" class="on">Show</a><a href="#hide" class="off">Hide</a></div><h3>Subscribe to a RSS Feed</h3><div class="content"><form action="/rss/sub" method="POST" id="Create_RSS_Sub"><div class="fields"><div class="field url"><label for="NEW_RSS_SUB_URL">URL:</label><input type="text" id="NEW_RSS_SUB_URL"'),s.r.attrs({value:{v:void 0,e:1}},s),s.push('/></div></div><div class="buttons"><button class="submit">Subscribe</button></div></form></div></div>')}),__.r.blockMod("a","RSS_Reader",__,function(s){s.push('<div id="New_RSS_Sub" class="box"><h3>RSS Feeds</h3><div class="content"><div class="intro">Subscribe to an RSS Feed.\nNews items will be streamed to\nyour chat window (ie left)\nas they arrive.</div><form action="/rss/sub" method="action" id="Create_RSS_Sub"><div class="fields"><div class="field link"><label>Feed Address:</label><input type="text" name="link"'),s.r.attrs({value:{v:void 0,e:1}},s),s.push('/></div></div><div class="buttons">'),s.r.call("span_as",{},s),s.push('<button class="submit">Subscribe</button></div></form></div></div>')});__.inc||__.r.done(__),cb(null,__.join(""),__)}
var runtime = require('./runtime');
var blade = runtime.blade;
exports.render = anonymous;
