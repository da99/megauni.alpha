class AlterHeartLinkImagesToAmazonS3s_13 < Sequel::Migration

  def up  
    # Grab the posts
    switch_to_a3 = lambda { |str|
      return nil if !str
      str.gsub( /([\"\'])[\.\/]{1,}media\/heart_links\/images/, "\\1http://surferhearts.s3.amazonaws.com/heart_links")
    }
    
    news_dt = dataset.from(:news)
    
    news_dt.select.all.each { |post|
      news_dt.where(:id=>post[:id]).update( 
        :teaser => switch_to_a3.call( post[:teaser] ),
        :body   => switch_to_a3.call( post[:body] )
      )
    }
  end

  def down
    
  end

end # === end AlterHeartLinkImagesToAmazonS3s
