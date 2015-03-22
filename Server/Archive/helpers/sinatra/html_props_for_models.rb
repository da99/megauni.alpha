# =========================================================
# Sinatra helpers for describing model instances as HTML/CSS properties.
# =========================================================


helpers do      

    def english_name(record_or_model)
      if record_or_model.respond_to?(:superclass) && record_or_model.superclass.eql?(Sequel::Model)
          record.name.underscore.gsub('_',' ')
      else
          record_or_model.class.name.underscore.gsub('_',' ')
      end
    end

    # Creates an HTML id to be used in the HTML DOM.
    # New records use an id of zero.
    def html_id(record)
      "#{record.class.name.underscore}_#{record[:id].to_i}"
    end # === def html_id

    # If record does not respond to :css_classes, 
    # then a generic css class name is used.
    # E.g.:  newspaper_article
    def css_classes(mod)
      if mod.respond_to?(:css_classes)
          return mod.css_classess
      else
          mod.class.name.underscore
      end
    end # === css_classes          
    
    # Creates a new path based on the paths from the action properties in
    # SSControllers.controllers.
    # E.g.:
    #  /x/1/2 ==> /x/:newspaper_id/:id
    #  /23      ==>  /:id 
    def a_href(controller_or_record, action_name, parent_record = nil)
      if controller_or_record.is_a?(Sequel::Model) 
          controller_name = controller_or_record.class.name.to_sym
          record = controller_or_record
      else
          controller_name = controller_or_record.to_sym
          record = Object.const_get(controller_name).new
      end
      
      action_props = SSControllerBase.controllers[controller_name][action_name]
      if !action_props
          raise "UNKNOWN PROPS FOR ACTION: #{controller_name.inspect} #{action_name.inspect}"
      end
      
      if action_name == :new
          raise ArguementError, "Parent record required for :new action." if !parent_record
          ancestor_records = parent_record.ancestor_records + [parent_record]
          new_path = action_props[:path]
      else
          raise ArguementError, "Record required." if !record
          ancestor_records = record.ancestor_records
          new_path = action_props[:path].sub(':id', record[:id])
      end
      
      ancestor_records.inject(new_path) { |m, rec|
          m.sub(":#{rec.class.name.underscore}_id", rec[:id])
      }
    end # === def a_href

    
end # === module Helpers

    


