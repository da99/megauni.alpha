class CreateIssues < Sequel::Migration

  def up
    create_table( :issues ) {
    
      # === Attributes
      primary_key :id
      
      varchar :app_name, :null=>false, :size=>25
      varchar :title, :size=>255, :null=>false
      text    :body, :null=>false
      varchar :category, :null=>false
      varchar :user_agent, :null=>false
      cidr    :ip_address, :null=>false
      boolean :resolved, :null=>false, :default=>false

      # === Date Times
      timestamp :created_at, :null=>false

      # ==== Aggregates
      # None.
    }          
  end

  def down
    drop_table :issues  if table_exists?(:issues)
  end

end # ---------- end CreateMembers



