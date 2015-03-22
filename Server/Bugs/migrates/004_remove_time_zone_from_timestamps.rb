class RemoveTimeZoneFromTimestamps_4 < Sequel::Migration

  def up  
    set_column_type :issues, :created_at, :"timestamp without time zone"      
    set_column_type :mini_issues, :created_at, :"timestamp without time zone"  
  end

  def down
    set_column_type :issues, :created_at, :"timestamp with time zone"      
    set_column_type :mini_issues, :created_at, :"timestamp with time zone"  
  end

end # === end CreateRemoveTimeZoneFromTimestamps
