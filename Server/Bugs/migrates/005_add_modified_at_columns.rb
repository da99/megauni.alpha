class AddModifiedAtColumns_5 < Sequel::Migration

  def up  
    [:issues, :mini_issues].each {|t|
      add_column t,  :modified_at, :timestamp , :null=>true
      dataset.from(t).update(:modified_at=>Time.now.utc)
    }
    
  end

  def down
    [:issues, :mini_issues].each {|t|
      drop_column t,  :modified_at
    }  
  end

end # === end CreateAddModifiedAtColumns
