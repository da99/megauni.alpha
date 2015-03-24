
require './Server/Customer/Log_In_By_IP'
require 'datoki'

class Customer

  include Datoki

  # =====================================================
  # Settings
  # =====================================================

  Table_Name = :customer
  TABLE = DB[Table_Name]

  # =====================================================
  # Errors
  # =====================================================
  Wrong_Pass_Word = Class.new(RuntimeError)
  Too_Many_Bad_Logins = Class.new(RuntimeError)

  # =====================================================
  # Class
  # =====================================================

  class << self

    def create *args
      r = new
      r.create *args
    end

  end # === class self

  # =====================================================
  # Instance
  # =====================================================

  field(:ip) {
    varchar
    matches(/\A[0-9\.\:]{5,}\Z/.freeze)
  }

  field(:pass_word) {
    pseudo
    varchar 8, 300
    on_empty 'Pass phrase is required.'
    on_short 'Pass phrase is not long enough.'
    on_long  'Pass phrase is too big.'
    be(lambda { |v| v.split.size >= 3 }, 'Pass phrase must be three words or more... with spaces.')
  }

  field(:confirm_pass_word) {
    pseudo
    must_equal 'Pass phrase confirmation does not match with pass phrase.' do |r, raw|
      raw[:pass_word]
    end
  }

  field(:pswd_hash) {
    set_to do |r|
      encode_pass_word(r.clean[:pass_word])
    end
  }

  def create
    clean(:ip, :pass_word, :confirm_pass_word, :pswd_hash)
  end # === create

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

end # === Customer


