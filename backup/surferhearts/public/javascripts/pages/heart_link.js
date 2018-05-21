                // --------------------------------------------------------------------------------------------------------------
                // Put all event observers here for page. -----------------------------------------------------------------------
                // --------------------------------------------------------------------------------------------------------------
                Event.observe(window, 'load', apply_behaviours);
                
                
                // --------------------------------------------------------------------------------------------------------------
                // Define variables for page here, including behaviour rules ----------------------------------------------------
                // --------------------------------------------------------------------------------------------------------------
                var page_rules = {
                    // '#form_post_comment .btn_submit' : function(ele){ ele.onclick = submit_form_post_comment;},
                    // '#form_post_comment' : function(ele) { ele.action = '/post/heart_link_comment/'; ele.method='post' },
                    // 'textarea' : function(ele){create_text_editor(ele);},
                    '#main_column div.datetime' : function (ele){ele.innerHTML=set_publish_date(ele.title);}
                
                }; // end var page_rules
                
                // --------------------------------------------------------------------------------------------------------------
                //  Put all functions for this page here ------------------------------------------------------------------------
                // --------------------------------------------------------------------------------------------------------------
                function apply_behaviours() {
                    if(document.getElementById('comments'))
                        page_rules['#comments span.datetime'] = function (ele){ele.innerHTML=set_publish_date(ele.title);};
                    Behaviour.register(page_rules);
                    Behaviour.apply();
                }; // end function apply_behaviours
                
                function create_text_editor(oTXT) {

                    if( !oTXT ) {
                        alert('Textarea not found');
                        return false;
                    }
                    var oFCKeditor  = new FCKeditor( oTXT.name ) ;
                    oFCKeditor.BasePath = '/javascripts/FCKeditor/' ;
                    oFCKeditor.ToolbarSet = 'Public';
                    oFCKeditor.Height = '100%'; 
                    oFCKeditor.ReplaceTextarea() ;
                }; // end function create_text_editor
                
                function submit_form_post_comment() {
                    document.getElementById('form_post_comment').submit();
                    return true;
                }; // end function submit_form_post_comment
                
                function set_publish_date(dt_string) {
                    if(!dt_string)
                        return dt_string;
                    var dt = new Date();
                    dt.setTime(Date.parse(dt_string));
                    return  dt.toLocaleString().replace(/\:\d\d /,' ');
                }; // end function set_publish_date
                // --------------------------------------------------------------------------------------------------------------
                // --------------------------------------------------------------------------------------------------------------
                // --------------------------------------------------------------------------------------------------------------