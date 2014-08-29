
require './Server/Customer/model'

module Customer_Test

  PSWD = "this is a pass"

  class << self

    def create
      sn = Screen_Name_Test.new_screen_name
      Customer.create screen_name: sn,
        pass_word: PSWD,
        confirm_pass_word: "this is a pass",
        ip: '000.00.000'
    end

    def find n = 0
      rec = Customer::TABLE.order_by(:id).limit(1, n).last

      c   = Customer.new(rec)
      sn  = Screen_Name.new(Screen_Name::TABLE[owner_id: c.id, is_sub: false])
      {c: c, sn: sn, pw: PSWD}
    end

    def list num = nil
      @customers ||= [create, create]
      return @customers if num.nil?
      @customers[num]
    end

  end # === class self

end # === module Customer_Test ===

