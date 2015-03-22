require 'blankslate'

class Sentry_Sender < BlankSlate
  
  attr_reader :scope, :on_method_missing

  def initialize scope, missing_method, &blok
    @scope = scope
    @on_method_missing = missing_method
    instance_eval(&blok) if block_given?
  end

  def method_missing name, *args, &blok
    scope.respond_to?(name) ?
      scope.send( name, *args, &blok ) :
      scope.send( on_method_missing, name, *args, &blok )
  end

end # === Sentry_Sender
