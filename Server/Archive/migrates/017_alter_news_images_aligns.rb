class AlterNewsImagesAligns_17 < Sequel::Migration

  def up  
    switch_align = lambda { |txt| 
      txt.gsub(/align\="(left|right)"/i , '')
    }
    news_dt = dataset.from(:news)
    
    news_dt.select.all.each { |post|
      news_dt.where(:id=>post[:id]).update( 
        :body   => switch_align.call( post[:body] )
      )
    }
  end

  def down
  end

end # === end AlterNewsImagesAligns
