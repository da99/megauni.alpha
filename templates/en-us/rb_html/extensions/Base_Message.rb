require 'models/Data_Pouch'
require 'models/Config_Switches'

module Ruby_To_Html::Base_Message

  ACCEPT = 1
  DECLINE = -1
  PENDING = 0

  def loop_messages_with_opening mess, h4_txt, empty_txt = nil
    text(capture {

      show_if("#{mess}?") {
        h4 h4_txt
      }

      if !!empty_txt
        show_if("no_#{mess}?"){
          div.empty_msg empty_txt
        }
      end

      loop_messages mess
    })
  end

  def loop_messages coll_name, &blok
    
    opts = Config_Switches.new {
      switch :meta, on
      switch :permalink, on
    }
    opts.put(&blok) if blok

    text(capture { 
      loop coll_name  do
        div.message {
          
          show_if 'suggest?' do
            show_if('accepted?') {
              div.accepted { span 'Accepted' }
            }
            show_if('pending?') {
              div.pending { span 'Pending' }
            }
            show_if('declined?') {
              div.declined { span 'Declined' }
            }
          end
        
          show_if 'title?' do
            h5 {
              a 'title'.m!, :href=>'href'.m!
            }
          end

          div.body( '{{{compiled_body}}}' )
          
          div.owner {
            span 'Author: '
            
            show_if 'owner?' do
              span 'you'
            end
          
            if_not 'owner?' do
              a('{{owner_username}}', :href=>'{{owner_href}}')
            end
              
          }

          logged_in {
          show_if 'has_parent_message?' do
            show_if 'suggest?' do
              show_if 'parent_message_owner?' do
                
                div.toggle_suggest {
                  toggle_form('message_accept', '{{href}}', :owner_accept) {
                    
                  div {
                      show_if 'not_accepted?' do
                        toggle('Accept', ACCEPT)
                      end
                      
                      show_if 'pending?' do
                        span ' or '
                      end
                      
                      show_if 'not_declined?' do
                        toggle('Decline', DECLINE)
                      end
                      
                      show_if 'not_pending?' do
                        span ' or '
                        toggle('I don\'t know.', PENDING)
                      end
                    }
                  }
                }
              end
            end
          end
          }

          show_if 'has_parent_message?' do
            div.permalink {
              a('reply', :href=>"{{href}}")
            }
          end

          if opts.ask.permalink?
            show_if 'parent_message?' do
              div.permalink {
                logged_in do
                  a('Reply', :href=>"{{href}}")
                  span " to this "
                  strong " {{message_model_in_english}} "
                end
                show_if 'not_logged_in?' do
                  a('link to this {{message_model_in_english}}', :href=>'{{href}}')
                end
              }
            end
          end
        }
      end
    })
  end

  def post_message raw_opts = {}, &blok
    
    opts = Config_Switches.new {
      switch :input_title, off
      strings :title, :css_class
      array :models
      hash :hidden_input
      put &blok
    }
    
    ask = opts.ask
    get = opts.get

    message_model = get.hidden_input[:message_model]
    
    english = [ 
      ['random'   , 'Random Thought']      ,
      ['news'     , 'Important News']      ,
      ['question' , 'Question']            ,
      ['fact'     , 'Encyclopedia Chapter'],
      ['e_chapter', 'Encyclopedia Chapter'],
      ['e_quote', 'Quote'],
      ['chapter'  , 'Encyclopedia Chapter'],
      ['story'    , 'Story']               ,
      ['fight'    , 'Fight']               ,
      ['complaint', 'Complaint']           ,
      ['cheer', 'Praise & Cheer']           ,
      ['jeer', 'Criticize']           ,
      ['suggest', 'Suggestion'],
      ['debate'   , 'Friendly Debate']     ,
      ['plea'      , 'Request']                    ,
      ['buy'       , 'Product Recommendation']     ,
      ['prediction', 'Prediction']
    ]
    models = ask.models? ? get.models : english.map(&:first)
    div_attrs = {}
    if ask.css_class?
      div_attrs[:class] = get.css_class
    end
    add_javascript_file '/js/vendor/jquery.min.js'
    add_javascript_file '/js/pages/Megauni_Base.js'
    
    config = form_config
    config.put {
      id "form_club_message_create_#{rand(1000)}"
      action '/messages/'
    }
    
    text(capture {
    div.club_message_create(config.as_hash) do
      
      form_post config  do

        if ask.title?
          h4 get.title
        else
          h4 'Post a message:'
        end

        if not message_model
          fieldset {
            select(:name=>'message_model') {
              english.each do |val, name|
                option( name, :value=>val ) if models.include?(val)
              end
            }
          }
        end
      
        fieldset.hidden {
          input_hidden 'body_images_cache', ''
          input_hidden 'return_url'       , '{{url}}'
          
          get.hidden_input.each { |k,v|
            input_hidden k, v
          }

          show_if 'single_username?' do
            input_hidden 'username', '{{first_username}}'
          end

          if message_model
          end
        }

        if ask.input_title?
          fieldset 'Title:', ''
        end
        
        fieldset {
          textarea '', :name=>'body'
        }

        # fieldset {
        #   label "Labels (Separate each with a comma.)"
        #   input.text :type=>'text', :name=>'public_labels', :value=>''
        # }

        show_if 'multiple_usernames?' do
          fieldset {
            label 'Post as:'
            select(:name=>'owner_id') {
              loop 'multiple_usernames' do
                option '{{username}}', :value=>'{{username}}'
              end
            }
          }
        end

        button_create 'Save'
      end
    end
    })
  end

end # === Base_Message
