
class Js_Dsl

  def initialize &blok
    @txt = []
    if blok
      instance_eval( &blok )
    end
  end

  def to_s
    @txt.map(&:strip).join('; ') + ';'
  end

  def return_false
    @txt << 'return false'
    self
  end

  def id form_id
    @txt << "$('\##{form_id}')"
    self
  end

  def parent txt
    _push ".parent('#{txt}')"
  end

  def parent_form
    @txt << "$(this).parent('form')"
    self
  end

  def submit_form form_id
    id(form_id).submit();
    self
  end
  
  def submit
    last = @txt.pop
    @txt << (last + '.submit()')
    self
  end
  
  def a_submit form_id
    submit_form( form_id )
    return_false
  end

  def add_class txt
    @txt << (@txt.pop + ".addClass('#{txt}')")
    self
  end
  
  def remove_class txt
    @txt << (@txt.pop + ".removeClass('#{txt}')")
    self
  end
  
  def remove
    _push ".remove()"
    self
  end

  def this
    @txt << "$(this)"
    self
  end
  
  def element e_id, &blok
    @txt << "$('#{e_id}')"
    instance_eval( &blok )
    self
  end

  def parents txt = nil
    txt ? 
      _push(".parents('#{txt}')") :
      _push(".parents()")
    self
  end
  
  def attr name, content
    _push(".attr('#{name}', '#{content}')")
    self
  end

  private # =========================================================

  def _push txt
    @txt << (@txt.pop + txt.to_s)
    self
  end


end # === class Js_Dsl
