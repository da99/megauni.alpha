class CreateMiniIssues < Sequel::Migration

  def up
    create_table( :mini_issues ) {
    
      # === Attributes
      primary_key :id
      
      text    :title,  :null=>false
      text    :body,   :null=>false
      boolean :resolved, :null=>false, :default=>false

      # === Date Times
      timestamp :created_at, :null=>false

      # ==== Aggregates
      # None.
    }          
  end

  def down
    drop_table :mini_issues  if table_exists?(:mini_issues)
  end

end # ---------- end CreateMembers



