require 'models/Diff_Document'
require 'models/Member'

class Doc_Log

  include Go_Mon::Model

  enable_timestamps
  
  make :doc_id, :mongo_object_id
  make :editor_id, :mongo_object_id, [:in_array, lambda { manipulator.lifes._ids } ]
  
  make_psuedo :old_doc, :Hash
  make_psuedo :new_doc, :Hash
  
  make :diff, [:set_to, lambda { 
    demand :old_doc, :new_doc
    o = raw_data.old_doc
    n = raw_data.new_doc
    o.extend Go_Mon::Diff_Document
    o.diff_document n
  }]

  # ==== Associations ====
   
  has_one :editor, Member
  
  # ==== Getters ====
  
  class << self
  end # == self

  # ==== Authorizations ====

  class << self
    
    def create editor, raw_data
      new do
        self.manipulator = editor
        self.raw_data = raw_data
        demand :doc_id, :editor_id, :diff
        save_create
      end
    end

  end # == self
   
  def allow_to? action, editor
    case action
    when :create
      true
    when :read
      editor.is_a?(Member) && editor.admin?
    when :update
      false
    when :delete
      false
    end
  end

  # ==== Accessors ====

end # === end Doc_Log
