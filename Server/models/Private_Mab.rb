
class Private_Mab
  
  attr_reader :context, :log
  
  def initialize new_context
    @context = new_context
    @log     = {}
  end

  def log?(key)
    @log.has_key?(key.to_sym) || @log.has_key?(key.to_s)
  end

  def method_missing *args, &blok
    context.send(*args, &blok)
  end
      
end # === class Private_Mab

