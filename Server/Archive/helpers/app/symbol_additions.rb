class Symbol
  def bang_to_bang
    return self unless to_s['!']
    to_s.gsub('!','_bang').to_sym
  end
end
