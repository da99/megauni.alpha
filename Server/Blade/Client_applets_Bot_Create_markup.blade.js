function anonymous(locals,cb,__){with(__=__||[],__.r=__.r||blade.Runtime,__.func||(__.func={},__.blocks={},__.chunk={}),__.locals=locals||{},__.filename="/home/da/DEV/apps/okdoki/Client/applets/Bot_Create/markup.blade",__.locals)__.r.blockMod("a","Bot_Create",__,function(s){var _=Bots.Own.length?"has_bots":"";s.push('<div id="New_Bot"'),s.r.attrs({"class":{v:""+s.r.escape(null==(s.z=_)?"":s.z)+" box",e:1}},s),s.push('><div class="setting"><a href="#show" class="on">Show</a></div><h3>Create a Bot</h3><div class="content"><div class="list">');for(var a in Bots.Own){var e=Bots.Own[a].screen_name;s.push("<a"),s.r.attrs({href:{v:"/bot/"+s.r.escape(null==(s.z=e)?"":s.z),e:1}},s),s.push(">"+s.r.escape(""+s.r.escape(null==(s.z=e)?"":s.z))+"</a>"+" ")}s.push("</div>"),Bots.Own.length,s.push('<form action="/Bot" method="POST" id="Bot_Create"><div class="fields"><div class="field sub_sn"><label for="NEW_BOT_SCREEN_NAME">Screen Name:</label><input name="sub_sn" type="text" id="NEW_BOT_SCREEN_NAME"/></div></div><div class="buttons">'),s.r.call("span_as",{},s),s.push('<button class="submit">Create</button></div></form></div></div>')});__.inc||__.r.done(__),cb(null,__.join(""),__)}
var runtime = require('./runtime');
var blade = runtime.blade;
exports.render = anonymous;
