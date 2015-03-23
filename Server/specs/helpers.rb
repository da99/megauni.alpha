
require 'Bacon_Colored'
require 'pry'
require './Server/Customer/model'

def days_ago_in_sql days
  Sequel.lit(Okdoki::Model::PG::UTC_NOW_RAW + " - interval '#{days * 24} hours'")
end

def customer
  Customer.new(:data)
end

def less_than x
  lambda { |o| o < x }
end

def within_secs x
  lambda { |o|
    o.class.should.equal Time
    !!o && (Time.now.utc.to_i - o.to_i).abs < x
  }
end

def new_body
  @i ||= 0
  "text #{@i += 1}"
end

def should_args action, *args
  case action
  when :zero, 0
    [ args.shift, [], :==, [0] ]
  when :one, 1
    [ args.shift, [], :==, [1] ]
  when Proc
    [ args.shift, [], nil, [action] ]
  else
    expect = args.shift
    actual = args.shift
    [ actual, [], action, args.unshift(expect) ]
  end
end

def assert *args
  make_should *should_args(*args)
end

def assert_not old_args
  args = should_args(*old_args)
  args[1].push :not
  make_should *args
end

def make_should o, bes_nots, meth, args
  s = Should.new(o)
  (bes_nots || []).each { |m|
    s = s.send(m)
  }

  if meth
    s.be.send(meth, *args)
  else
    s.be(*args)
  end
end


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













































