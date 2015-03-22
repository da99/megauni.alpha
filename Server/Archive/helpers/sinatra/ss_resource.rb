require Pow!("ss_controller") if !Object.const_defined?(:SSControllerBase)

# ==============================================
# index       GET /posts        
# show       GET /posts/1      
# new         GET /posts/new    
# edit          GET /posts/1/edit 
# create      POST /posts       
# update     PUT  /posts/1     
# delete      DELETE /posts/1   
# 
# /posts/1/comments
# /posts/1/comments/2
# /posts/1/comments/new
# /posts/1/comments/2;edit
# ==============================================

module Sinatra

    module TheSSResource
    
        def self.registered( app )
            app.helpers Helpers
        end
        
        module Helpers
                  def just_one_model?
                    @family_models.size.eql?( 1  )
                  end # === def    
        
                    # If there is a Model class hierarchy, it loops through each 
                    # ancestor to see if it exists.
                    # Returns nil if there are no ancestors.
                  def ancestors_are_required!
                    return nil if just_one_model?
                    @family_models.slice( 0, @family_models.size - 1).each { |profile| 
                      if !profile[:record]
                        render_error_msg("#{english_name(profile[:model]).capitalize} not found.")
                      end
                    }
                  end # === def

                  def child_is_required!
                    if !@child
                      render_error_msg( "#{english_name(@child_model).capitalize} not found." )
                    end
                  end # === function: child_is_required!             
        
                  def find_instance_vars

                    @child_model   = controller_model_class
                    @family_models = [ ]

                    current_model = @child_model
                    while( current_model ) do
                    
                      @family_models.unshift( 
                      { :model    => current_model, 
                        :id       => 0,
                        :dataset  => current_model.name_underscored.pluralize + '_dataset' ,
                        :all_dataset =>  'all_' + current_model.name_underscored.pluralize + '_dataset'
                      } )
                      
                      current_model =  current_model.parent_model? ? 
                                       Kernel.const_get( current_model::PARENT_MODEL ) :
                                       nil
                    end # === while

                    @family_models.each_index { |i|
                      @family_models[i][:id] = Integer( Ramaze::Action.current.params[ i ] )
                    }

                    case current_action[:perm_level]
                    when Member::STRANGER 
                      @family_models.each_index { |i|
                        @family_models[i][:record] = @family_models[i][:model][:trashed=>false, :id=>@family_models[i][:id] ]
                      }
                    when Member::MEMBER 
                      @family_models.each_index { |i|
                        if i.zero?
                          @family_models[i][:record] = current_member.send("#{@family_models[i][:all_dataset]}")[ :id=>@family_models[i][:id] ]
                        elsif @family_models[i-1][:record] && @family_models[i][:id] > 0
                          @family_models[i][:record] = @family_models[i-1].send( @family_models[i][:all_dataset] )[ :id=>@family_models[i][:id] ]
                        else
                          @family_models[i][:record] = nil
                        end
                      }
                    end # === case

                    load_instance_vars
                    
                  end # === function: find_instance_vars


                  def load_instance_vars
                    # ======= create instance variables like: @newspaper, @section, @article, etc. ======================
                    # ================ also includes: @parent, @child, @parent_model, etc. ==============================
                    parent_index = @family_models.size - 2 
                    child_index  = @family_models.size - 1 
                    @family_models.each_index { |i|

                      if @family_models[i][:record]
                        instance_variable_set( :"@#{@family_models[i][:model].name_underscored}", @family_models[i][:record] )
                      end

                      if !just_one_model? && i === parent_index
                        @parent_profile = @family_models[i]
                        @parent         = @family_models[i][:record]
                        @parent_model   = @family_models[i][:model]
                        @parent_id      = @family_models[i][:id]
                        instance_variable_set( :"@#{@parent_model.name_underscored}_id", @parent_id )
                      end

                      if i ===  child_index
                        @child_profile = @family_models[i]
                        @child         = @family_models[i][:record] 
                        @child_id      = @family_models[i][:id]
                        instance_variable_set( :"@#{@child_model.name_underscored}_id", @child_id )
                      end

                    }
                    
                  end # === def
        end # === Helpers    
    
    end # === TheSSResource
    
    # register TheSSResource
    
end # === Sinatra


 # ================================================================
 # ================================================================


class SSControllerBase

    def show(*args, &old_proc)
      new_action_name, path, perm_level =  args
      props = resource_generic_props(__method_name_sym__ , :get, *args)
      eval( "
          get( #{props[:path].inspect} ) do |*args|
              
              describe_action( #{props.inspect} )
              
              find_instance_vars
              child_is_required!
              render_mab 
          end
      ", self.original_scope)   
    end

    def new(*args, &old_proc)
        props = resource_generic_props( __method_name_sym__ , :get, *args  )
        
        eval( "
            get( #{props[:path].inspect} ) do |*args|
                
                describe_action( #{props.inspect} )
                
                find_instance_vars
                ancestors_are_required!
                render_mab    
            end        
        " , self.original_scope)
    end

    def create(*args, &old_proc)
        props = resource_generic_props( __method_name_sym__ , :post, *args)
        
        eval( %~
            post( #{props[:path].inspect} ) do |*args|        
              describe_action( #{props.inspect} )
              
              find_instance_vars
              ancestors_are_required!

              begin
                @child = @child_profile[:record] ||= @child_model.new
                @child.changes_from_editor( clean_room , current_member )
                if just_one_model?
                  current_member.send( "add_\#{@child_model.name_underscored}", @child)
                else
                  @parent.send("add_\#{@child_model.name_underscored}", @child)
                end
                @child.save
                load_instance_vars
                render_success_msg( "Your info. has been saved." )
              rescue Sequel::ValidationFailed
                render_error_msg( @child.error_msg )
              end 
            end      
        ~, self.original_scope)
        
    end

    def edit(*args, &old_proc)
        props = resource_generic_props( __method_name_sym__, :get, *args )
        eval( "
          get( #{props[:path].inspect} ) do |*args|        
            
            describe_action( #{props.inspect} )
            
            find_instance_vars
            child_is_required!
            render_mab            
          end
        " , self.original_scope)
    end

    def update(*args, &old_proc)
        props = resource_generic_props( __method_name_sym__, :put, *args )
        eval( %~    
          put( #{props[:path].inspect} ) do |*args|        
            
            describe_action( #{props.inspect} )     
                           
            find_instance_vars
            child_is_required!

            begin
              @child.changes_from_editor( clean_room , current_member )
              @child.save
              @redirect_to = @child.a_href(:edit)
              render_success_msg(  "Your info. has been saved."  )
            rescue Sequel::ValidationFailed
              render_error_msg( @child.error_msg )
            end
           end
        ~ , self.original_scope)
    end


    
    def destroy(*args, &old_proc)
        props = resource_generic_props( __method_name_sym__, :delete, *args )
        eval( %~
          #{props[:http_verb]}( #{props[:path].inspect} ) do |*args|        
            
            describe_action( #{props.inspect} )    
            
            find_instance_vars
            child_is_required!
            @child.changes_from_editor( :destroy_it!, current_member)
            render_success_msg( "Your info. has been saved." )
            
          end
        ~ , self.original_scope)
    end
    
    private # ===========================================
    
    def resource_generic_path(http_verb, new_action_name)
        obj_class ||=  model_class(:required) 
        ancestors = model_class.ancestor_models
        prefix = (ancestors && !ancestors.empty?) ?
            ancestors.reverse.inject("") { |m, anc| m += "/#{anc.to_s.underscore}/:#{anc.to_s.underscore}_id" ; m}  :
            ""
        suffix = case new_action_name
            when :index
                "/#{model_class.to_s.pluralize.underscore}"
            when :new, :create
                "/#{model_class.to_s.underscore}"
             when :edit
                "/#{model_class.to_s.underscore}/:id/edit"
             else 
                "/#{model_class.to_s.underscore}/:id"
        end
        path = prefix + suffix
    end # === def
    
    def model_class(required = false)
        obj_class = Object.const_defined?(controller_name) ?
                                    Object.const_get(controller_name) :
                                    nil;
        if !obj_class && required
            raise "MODEL CLASS NOT FOUND: #{controller_name.inspect}"
        end   
        obj_class 
    end # === def    
    
    def resource_generic_props(new_action_name, http_verb, raw_path = nil, raw_perm_level = nil)
        perm_level = raw_perm_level || :MEMBER
        
        path = raw_path || resource_generic_path(http_verb, new_action_name)
        props = generic_props(new_action_name, http_verb, perm_level,  path)
        props[:model_class] = model_class
        props
    end
    
end # === SSControllerBase


__END__


    def trash(*args, &old_proc)
        props = resource_generic_props( __method_name_sym__, :put, *args )
        eval generic_action(  props, %~
            find_instance_vars
            child_is_required!
            @child.changes_from_editor( :trash_it!, current_member) 
            render_success_msg(  "Your info. has been saved."  )
        ~)
    end

    def untrash(*args, &old_proc)
        props = resource_generic_props( __method_name_sym__, :put, *args )
        body = %~
            find_instance_vars
            child_is_required!
            @child.changes_from_editor( :untrash_it!, current_member) 
            render_success_msg(  "Your info. has been saved."  )
        ~
        eval generic_action(props, body)
    end
