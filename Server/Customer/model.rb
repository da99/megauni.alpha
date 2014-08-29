
require './Server/Okdoki/model'
require './Server/Screen_Name/model'
require './Server/Customer/Log_In_By_IP'

require_crud :Customer

class Customer

  include Okdoki::Model
  attr_reader :clean_data

  # =====================================================
  # Settings
  # =====================================================

  Table_Name = :customer
  TABLE = DB[Table_Name]

  # =====================================================
  # Errors
  # =====================================================
  Wrong_Pass_Word = Class.new(Okdoki::Invalid)
  Too_Many_Bad_Logins = Class.new(Okdoki::Invalid)

  # =====================================================
  # Class
  # =====================================================

  class << self
  end # === class self

  # =====================================================
  # Instance
  # =====================================================

  def initialize *args
    super
  end

  # NOTE: We have to put newlines. In case of an error,
  # the error message won't include the pass_word if the pass_word
  # is on it's own line.
  def encode_pass_word val
    Sequel.lit "\ncrypt(\n?\n, gen_salt('bf', 13))", val
  end

  # NOTE: We have to put newlines. In case of an error,
  # the error message won't include the pass_word if the pass_word
  # is on it's own line.
  def decode_pass_word val
    Sequel.lit "\ncrypt(\n?\n, pswd_hash)", val
  end

  def validate name
    case name
    when :pass_word
      super(name).
        at_least(6, 'Pass phrase is too short.').
        at_most(300, 'Pass phrase is too big.').
        be(lambda { |v| v.split.size >= 3 }, 'Pass phrase must be three words or more... with spaces.')
    when :confirm_pass_word
      super.
        equals(clean_data[:pass_word], "Pass phrase is different than pass phrase confirmation.")
    when :email
      raise "not ready"
    when :ip
      super.
        required('IP address is required.').
        be(lambda { |v| v.size > 5 }, 'Valid ip address is required.')
    else
      super
    end # === case
  end # === def validate

end # === Customer


