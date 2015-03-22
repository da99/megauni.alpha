

helpers {

  def crud! raw_model_class = nil, raw_action_name = nil

    model_class = raw_model_class || 
                  Object.const_get(
                    request.path.split('/')[1].split('_').map(&:capitalize).join('_')
                  )
    action_name = raw_action_name || begin
      if request.get? && request.path =~ /\/edit/
        :edit
      elsif request.get? && request.path =~ /\/new\//
        :new
      elsif request.get?
        :show
      elsif request.post?
        :create
      elsif request.put?
        :update
      elsif request.delete?
        :delete
      else
        raise "Oh, c'mon?!?!"
      end
    end

    action action_name
    model  model_class

    require_log_in! if require_log_in?

    case action

      when :new

        begin
          doc model.new(current_member)
        rescue model::Unauthorized_New
          not_found
        end

        return render_mab

      when :show
        begin
          doc model.read current_member, clean_room[:id]
        rescue model::Not_Found, model::Unauthorized_Reader
          not_found
        end
        
        return render_mab

      when :edit
        begin
          doc model.edit current_member, clean_room[:id]
        rescue model::Not_Found, model::Unauthorized_Editor
          not_found
        end

        return render_mab

      when :create
        begin
          doc               model.create current_member, clean_room
          flash.success_msg = ( success_msg || 'Successfully saved data.')
          redirect(redirect_success ||  "/#{model_underscore}/#{doc.data._id}/" )

        rescue model::Unauthorized_Creator
          halt(404, "Page Not Found.")

        rescue model::Invalid
          flash.error_msg =  ( error_msg   ||  to_html_list($!.doc.errors) )
          redirect( redirect_error || "/#{model_underscore}/new/"  )
        end

      when :update
        begin
          doc               model.update(current_member, clean_room)
          flash.success_msg = ( success_msg  || "Updated data." )
          redirect( redirect_success || request.path_info )

        rescue model::Not_Found, model::Unauthorized_Updator
          not_found

        rescue model::Invalid
          flash.error_msg = ( error_msg || to_html_list($!.doc.errors) )
          redirect( redirect_error || "/#{model_underscore}/#{$!.doc.data._id}/edit/" )
        end

      when :delete
        begin
          doc               model.delete!( current_member, clean_room[:id])
          flash.success_msg = ( success_msg ||  "Deleted." )
        rescue model::Not_Found, model::Unauthorized_Deletor
          flash.success_msg = "Deleted."
        end

        redirect( redirect_success || '/my-work/' )
        
      else
        raise ArgumentError, "Invalid action: #{action_name}"
    end

  end
}



# =========================================================
#                 OUTDATED. DElete It.
# =========================================================

configure do 

  class CRUD_DSL

    # === CONSTANTS ===================================

    OPTIONS =  [ 
      :require_log_in, 
      :model_class, 
      :model_underscore, 
      :action,
      :path, 
      :path_options,
      :http_method, 
      :success_msg, 
      :error_msg, 
      :redirect,
      :redirect_error,
      :redirect_success
    ]

    ACTIONS = [:new, :show, :edit, :create, :update, :delete].uniq

    attr_reader :options, :model_class, :model_underscore

    def initialize new_model_class, &blok
      @options          = {}
      @model_class      = new_model_class
      @model_underscore = model_class.to_s.underscore

      instance_eval( &blok )

      options_to_struct

      this_options = @options
      this_model   = @model_underscore
      self.class.instance_eval {
        configure {
          set "crud_#{this_model}", this_options
        }
      }
    end


    def default_http_method 
      case action
        when :new;    :get
        when :show;   :get
        when :edit;   :get
        when :create; :post
        when :update; :put
        when :delete; :delete
      end
    end

    def default_path
      case action
        when :new;      "/#{model_underscore}/new/"
        when :show;     "/#{model_underscore}/:id/"
        when :edit;     "/#{model_underscore}/:id/edit/"
        when :create;   "/#{model_underscore}/"
        when :update;   "/#{model_underscore}/:id/"
        when :delete;   "/#{model_underscore}/:id/"
      end
    end

    def manipulator_name action_name
      case action_name
        when :new;     :new
        when :create;  :creator
        when :updator; :updator
        when :edit;    :editor
        when :show;    :reader
        when :delete;  :deletor
      end
    end

  end # === class CRUD_DSL 

end # === configure


