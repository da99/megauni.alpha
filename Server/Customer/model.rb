
require './Server/Customer/Log_In_By_IP'
require 'datoki'

class Customer

  include Datoki

  field(:ip) {
    string_ish 7, 50, /\A[0-9\.\:]{5,}\Z/.freeze
    mis_match 'Invalid format for IP address: {{raw}}'
  }

  field(:pass_word) {
    pseudo
    varchar 8, 300, lambda { |v| v.split.size >= 3 }

    mis_match 'Pass phrase must be three words or more... with spaces.')
    required  'Pass phrase is required.'
    small     'Pass phrase is not long enough.'
    big       'Pass phrase is too big.'
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
    clean! :pass_word, :confirm_pass_word, :pswd_hash
  end # === create


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
  #
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


