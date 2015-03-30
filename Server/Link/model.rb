
class Link

  include Datoki

  field(:owner_id) {
    integer
  }

  field(:type_id) {
    smallint
  }

  field(:left_id) {
    integer
  }

  field(:right_id) {
    integer
  }

  class << self
  end # === class << self

  def create
    clean! :owner_id, :type_id, :left_id, :right_id
  end

end # === Link
