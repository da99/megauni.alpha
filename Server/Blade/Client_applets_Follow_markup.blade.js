function anonymous(locals,cb,__){with(__=__||[],__.r=__.r||blade.Runtime,__.func||(__.func={},__.blocks={},__.chunk={}),__.locals=locals||{},__.filename="/home/da/DEV/apps/okdoki/Client/applets/Follow/markup.blade",__.locals)is_customer&&!is_owner&&(__.push('<div id="Follow"'),__.r.attrs({"class":{v:""+__.r.escape(null==(__.z=is_following&&"is_following")?"":__.z)+" box",e:1}},__),__.push('><div class="content"><form method="POST" id="Delete_Follow"'),__.r.attrs({action:{v:"/me/"+__.r.escape(null==(__.z=screen_name)?"":__.z)+"/follow",e:1}},__),__.push('><div class="buttons"><div class="intro">You\'re subscribed.</div><input type="hidden" name="_method" value="DELETE"/><button class="submit">Unsubscribe</button></div></form><form method="POST" id="Create_Follow"'),__.r.attrs({action:{v:"/me/"+__.r.escape(null==(__.z=screen_name)?"":__.z)+"/follow",e:1}},__),__.push(">"),__.r.call("applet",{},__,"as_this_life"),__.push('<div class="buttons"><button class="submit">Subscribe</button></div></form></div></div>'));__.inc||__.r.done(__),cb(null,__.join(""),__)}
var runtime = require('./runtime');
var blade = runtime.blade;
exports.render = anonymous;
