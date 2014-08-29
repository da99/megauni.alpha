
require './Server/Customer/model'
require './Server/Customer/specs/helpers' unless Object.const_defined?(:Customer_Test)

module Screen_Name_Test

  class << self

    def delete
      @screen_names = nil
      Screen_Name::TABLE.delete
      true
    end

    def new_screen_name
      "ted_#{Time.now.strftime("%m%d%H%M%S%3N")}"
    end

    def create customer = nil
      name = new_screen_name
      c = customer || Customer.new({id: rand(10000000)})

      Screen_Name.create(:screen_name=>name, :customer=>c)
    end

    def list num = nil
      @screen_names ||= 4.times.map do |i|
        create(Customer_Test.create)
      end

      return @screen_names if num.nil?
      @screen_names[num]
    end

  end # === class self

end # === module Screen_Name_Test ===



