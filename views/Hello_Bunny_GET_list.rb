class Hello_Bunny_GET_list < Bunny_Mustache

  def title
    'Coming Soon...'
  end

  def meta_description
    @app.class::SITE_TAG_LINE
  end

  def meta_keywords
    @app.class::SITE_KEYWORDS
  end

   
end # === Hello_Bunny_GET_list
