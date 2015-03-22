
def resty(model_name_sym, &blok)
  Resty.new(model_name_sym, &blok)
end


helpers {

  # === Use the following actions in your views. ===============================

  def current_resty
    @resty_props ||= {}
  end

  def is_creator?(model_name= nil)

    return false if !logged_in?
    
    model_class = if model_name
      Object.const_get(model_name.to_s.underscore.camelize)
    else
      current_resty[:model_class] || 
        Object.const_get(controller.to_s.camelize)
    end
    
    return false if !model_class

    resty = Resty.find(:create, model_class)
    return false if !resty

    resty.creators.keys.detect { |l|
      current_member.has_power_of? l
    }
  end

  def is_updator?(instance = nil)
    instance ||= current_resty[:instance]
    return false if !instance
    resty = Resty.find(:update, instance.class)
    return false if !resty
    current_member_allowed_to?(instance, resty.updators.keys)
  end

  def is_deletor?(instance = nil)
    instance ||= current_resty[:instance]
    return false if !instance
    resty = Resty.find :delete, instance.class
    return false if !resty
    current_member_allowed_to?(instance, resty.deletors)
  end


  # === The following actions are used only by Resty actions. ============================
  # === They are not meant to be used by regular actions. ================================

  # Use an action like: "/:model/:id/"
  def validate_as_resty!
    
    raise ArgumentError, "Put ':model' in the path." if !clean_room[:model]
    model_name  = clean_room[:model].underscore.camelize
    model_class = Object.const_defined?(model_name.camelize) && Object.const_get(model_name.camelize)
    action      = default_resty_action
    
    resty = Resty.find(action, model_class)
    # dev_log_it [action, model_class].inspect # resty.inspect
    
    pass if !resty # === This means this is not a resty action.

    case action
      when :create, :new
        l = require_log_in! resty.creators.keys
        return nil if !l
        describe_resty  :security_level=>l, 
                        :columns=> resty.creators[l],
                        :model_class=>model_class

      when :update, :edit
        i, l  = get_model_instance_and_validate_editor model_class, resty.updators.keys
        return nil if !i
        describe_resty  :instance=>i,
                        :security_level=>l,
                        :columns=>resty.updators[l]

      when :delete
        i, l = get_model_instance_and_validate_editor model_class, resty.deletors
        return nil if !i 
        describe_resty :instance=>i,
                       :security_level=>l

      when :show
        if resty.viewers.keys.include?(:STRANGER)
          i = get_model_instance_or_raise(model_class)
          return nil if !i
          describe_resty :instance=>i,
                         :security_level=>:STRANGER
        else
          i, l = get_model_instance_and_validate_editor model_class, resty.viewers.keys
          return nil if !i
          describe_resty :model_class=>model_class,
                         :instance=>i,
                         :security_level=>l
        end
    end # === case action

    describe( model_name.to_sym, action )
    true

  end # === def



  def get_model_instance_and_validate_editor( model_class, resty_roles)
    i = get_model_instance_or_raise model_class
    l = validate_editor i, resty_roles
    [i, l]
  end

  def validate_editor( instance, resty_roles )
    require_log_in!
    level    = current_member_allowed_to?(instance, resty_roles)
    return level  if level
    not_found 
  end # === def

  def get_model_instance_or_raise(model_class)
    instance = model_class[:id=>clean_room[:id]]
    not_found if !instance
    instance
  end

  def describe_resty(props)
    @resty_props = props.freeze
  end

  def current_member_allowed_to?(instance, resty_roles)
    member_levels = resty_roles.select { |l| !instance.respond_to?(l) }
    i_meths       = resty_roles - member_levels
    in_assoc      = i_meths.detect { |i| instance.send(i).include?(current_member) }
    level         = member_levels.detect { |l| current_member.has_power_of?(l) }
    return(in_assoc || level)  if in_assoc || level    
    false
  end



} # === helpers
