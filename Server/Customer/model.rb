
require 'datoki'

class Customer

  include Datoki

  # field(:ip) {
    # string_ish 7, 50, /\A[0-9\.\:]+\Z/.freeze
    # mis_match 'Invalid format for IP address: {{raw}}'
  # }

  field(:pass_word) {
    pseudo
    string_ish 10, 300, lambda { |v| v.split.size >= 3 }

    mis_match 'Pass phrase must be three words or more... with spaces.'
    small     'Pass phrase is not long enough: at least {{min}} characters.'
    big       'Pass phrase is too big.'
  }

  field(:confirm_pass_word) {
    string_ish
    pseudo
    matches do |r, raw|
      r.raw[:pass_word] == raw
    end
    mis_match 'Pass phrase confirmation does not match with pass phrase.'
  }

  field(:pswd_hash) {
    string_ish 10, 100
    set_to do |r|
      r.encode_pass_word(r.clean[:pass_word])
    end
  }

  def create
    sn = Screen_Name.create(@raw)
    clean[:id] = sn.data[:id]
    clean! :pass_word, :confirm_pass_word, :pswd_hash
  end # === create


  # =====================================================
  # Class
  # =====================================================

  class << self
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


