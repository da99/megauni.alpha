class CreateToDos_14 < Sequel::Migration

  def up  
    create_table( :to_dos ) {
      # === Associations
      primary_key :id
      foreign_key :owner_id,   :members
      foreign_key :project_id, :projects

      # === Attributes
      smallint :category,   :default => 0,  :null => false
      varchar  :title
      text     :details
      smallint :days
      smallint :hours
      smallint :minutes
      smallint :seconds
      
      # === Date Times
      timestamp :starts_at,   :null=>true
      timestamp :ends_at,     :null=>true
      timestamp :created_at
      timestamp :update_at, :null=>true

      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:to_dos) if table_exists?(:to_dos)
  end

end # === end CreateToDos
