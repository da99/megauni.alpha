function anonymous(locals,cb,__){with(__=__||[],__.r=__.r||blade.Runtime,__.func||(__.func={},__.blocks={},__.chunk={}),__.locals=locals||{},__.base="/home/da/DEV/apps/okdoki",__.rel="Client/Screen_Name/me",__.filename="/home/da/DEV/apps/okdoki/Client/Screen_Name/me/markup.blade",__.locals)__.r.include("../../layout.blade",__),__.r.func("folder",function(s,a){s.push("<li"),s.r.attrs({id:{v:this.id},"class":{v:this.classes,a:"folder"}},s),s.push('><a class="open"'),s.r.attrs({href:{v:"/me/"+s.r.escape(null==(s.z=screen_name)?"":s.z)+"/folder/"+s.r.escape(null==(s.z=a.num)?"":s.z),e:1}},s),s.push(">"+s.r.escape(""+s.r.escape(null==(s.z=a.title)?"":s.z))+"</a>"+"</li>")},__),__.r.blockMod("a","templates",__,function(s){is_customer&&s.push('<div class="customer_screen_names">'+s.r.escape(""+s.r.escape(null==(s.z=customer_screen_names.join(" "))?"":s.z))+"</div>"),s.r.call("folder",{},s,{num:"{num}",title:"{title}"}),s.push('<div class="msg"><div class="meta"><span class="author"><a href="/me/{author_screen_name}">{author_screen_name}</a></span><span class="said"> said:</span></div><div class="content">{body}</div></div><div class="msg me_msg"><div class="meta"><span class="author">{author_screen_name} (me)</span><span class="said"> said:</span></div><div class="content">{body}</div></div><div class="msg chat_msg"><div class="meta"><span class="author">{author_screen_name}</span><span class="said"> said:</span></div><div class="content">{body}</div></div><div class="msg chat_msg me_chat_msg"><div class="meta"><span class="author">{author_screen_name} (me)</span><span class="said"> said:</span></div><div class="content">{body}</div></div><div class="msg official chat_msg"><div class="content">{body}</div></div><div class="msg official chat_msg errors"><div class="content">{body}</div></div>')}),__.r.blockMod("a","content",__,function(s){s.push('<div id="Me"><div class="box"><h3><span>Box</span><span class="sub">(Mail)</span></h3><div class="content">[placeholder]</div></div></div><div id="Sidebar"><div id="Me_Intro"><div class="the_life_of">The life of...</div><h3 class="name">'+s.r.escape(""+s.r.escape(null==(s.z=screen_name)?"":s.z))+"</h3>"+"</div>"+"<div"+' class="box"'+">"+"<h3"+">"+"~ ~ ~"+"</h3>"+"<div"+' class="content"'+">"+"* * *"+"</div>"+"</div>"+"</div>")});__.inc||__.r.done(__),cb(null,__.join(""),__)}
var runtime = require('./runtime');
var blade = runtime.blade;
exports.render = anonymous;
