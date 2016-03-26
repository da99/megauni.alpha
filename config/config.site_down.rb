before {


  if request.xhr?
    halt( "<div class=\"error\">Website is undergoing maintainence. Please try again in 90 seconds.</error>" )
  end
  
  try_again_function = if request.get?
    %~
      window.location.reload()
    ~
  else
    %~
      window.history.go(-1)
    ~
  end
  
  halt %~
        <html>
          <head>
            <title>Site maintainence occurring.</title>
            <style type="text/css">
              body {
                font-family: monospace;
                font-size: 16px;
                text-align: center;
                padding-top: 20px;
              }
              #status_msg {
                font-size: 24px;
                border: 2px solid #f00919;
                background: #ff9;
              }
              p, #status_msg {
                width: 400px;
                margin: 0 auto;
                padding: 10px;
              }
            </style>
          </head>
          <body>
            <p>
              Site maintainence is occurring. Once the countdown is done, you can try again.
            </p>
            <div id="status_msg">90</div>
            <script>
              var started = (new Date()).getTime();
              var minutes = 1000 * 60;
              var ends = started + (minutes * 1.5);
              var timer_id = setInterval('update_page(ends, timer_id)',1000);
              
              function try_again() {
                #{ try_again_function }
              };
              
              function update_page(ends, timer_id) {
                var ele = document.getElementById('status_msg');
                var right_now = (new Date()).getTime();
                if( parseInt(ends - right_now) < 1 ) {
                  clearInterval(timer_id);  
                  ele.innerHTML = 'Reloading...';
                  try_again();
                } else {
                  ele.innerHTML = parseInt((ends - right_now)/1000) + '';
                };
              };
            </script>
          </body>
        </html>
  ~


}
