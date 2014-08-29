<!DOCTYPE html>
<html lang="en">
  <head>
    <title>{{intro}} {{sn_all}}</title>
    <meta content="text/html charet=UTF-8" http-equiv="Content-Type" />
    <meta content="no-cache, max-age=0, must-revalidate, no-store, max-stale=0, post-check=0, pre-check=0" http-equiv="Cache-Control" />
    <link href="/favicon.ico" rel="shortcut icon" />
    <link href="/css/lenka-stabilo.css?{{file_stamp}}" media="screen" rel="stylesheet" type="text/css" />
    <link href="/css/circus.css?{{file_stamp}}" media="screen" rel="stylesheet" type="text/css" />
    <link href="/css/vanilla.reset.css?{{file_stamp}}" media="screen" rel="stylesheet" type="text/css" />
    <link href="/css/okdoki.css?{{file_stamp}}" media="screen" rel="stylesheet" type="text/css" />
    <link href="/css/forms.css?{{file_stamp}}" media="screen" rel="stylesheet" type="text/css" />
    <link href="/applets/Create_Life/style.css?{{file_stamp}}" media="screen" rel="stylesheet" type="text/css" />
    <link href="/Customer/lifes/style.css?{{file_stamp}}" media="screen" rel="stylesheet" type="text/css" />
  </head>
  <body>{{#logged_in?}}    <div id="Nav_Bar"><a href="/log-out" id="Log_Out">Log-out</a>{{^is_customer_lifes}}<a class="home" href="/">My Account</a>{{/is_customer_lifes}}{{#my_other_screen_names}}<a class="screen_name" href="{{href}}">{{href}}</a>{{/my_other_screen_names}}</div>
    {{/logged_in?}}    <div id="Logo"><span class="wat_wat">My Account @ </span><span class="main">ok</span><span class="sub">doki</span></div>
    <div class="col" id="Interact">      <div class="box" id="Create_Life">        <div class="mini_box my_life">
          <h3>My Life(s):</h3>
          <div class="content">            <ul class="screen_names">{{#screen_names}}
              <li><a href="{{href}}">{{screen_name}}</a></li>
              {{/screen_names}}</ul>
          </div>
        </div>
        <div class="mini_box create_life">
          <h3>Create A New Life:</h3>
          <div class="content">            <form action="/@" id="Create_Screen_Name" method="POST">              <div class="fields">                <div class="field screen_name"><span class="label">Screen Name:</span><input maxlength="40" name="screen_name" type="text" value="" /></div>
              </div>
              <div class="buttons"><button class="submit">Create</button></div>
            </form>
          </div>
        </div>
      </div>
    </div>
    <div class="col" id="Msgs">      <div id="Headlines"></div>
    </div>
    <script id="CSRF" type="text/_csrf">{{_csrf}}</script>
    <script id="js_templates" type="text/x-okdoki">      <div class="loading msg"></div>
      <div class="success msg"></div>
      <div class="errors msg"></div>
      <li class="screen_name"><a class="name" href="{href}"></a></li>
    </script>
    <script src="/js/vendor/all.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/Common.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/Box.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/Event.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/DOM.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/Ajax.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/Adaptive.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/Time.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/Template.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/Form.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/Screen_Name.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/js/Customer.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/applets/Create_Life/script.js?{{file_stamp}}" type="text/javascript"></script>
    <script src="/Customer/lifes/script.js?{{file_stamp}}" type="text/javascript"></script>
  </body>
</html>
