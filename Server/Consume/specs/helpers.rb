
require "./Server/Consume/model"

module Consume_Test

  class << self

    def delete
      Consume::TABLE.delete
    end

  end # === class self

end # === module Follow ===
