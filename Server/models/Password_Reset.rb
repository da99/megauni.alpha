

class Password_Reset

  include Go_Mon::Model

  attr_reader :code

  # ==== CONSTANTS ====
  
  In_Reset       = Class.new( StandardError )
  Not_In_Reset   = Class.new( StandardError )
  Invalid_Code   = Class.new( StandardError )
  
  # ==== Fields  ====
  
  enable_timestamps
  make :owner_id, :mongo_object_id
  make :salt, :anything
  make :hashed_code, :anything

  # ==== Associations  ====
    
  belongs_to :owner, :Member

  # ==== Class Methods ====
  
  class << self

    def create member

      code = begin
               # Salt and encrypt values.
               chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
               (1..10).inject('') { |new_pass, i|  
                 new_pass += chars[rand(chars.size-1)] 
                 new_pass
               }
             end
      
      salt = begin
               # Salt and encrypt values.
               chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
               (1..10).inject('') { |new_pass, i|  
                 new_pass += chars[rand(chars.size-1)] 
                 new_pass
               }
             end

      hashed_code = BCrypt::Password.create( code + salt ).to_s
      
        # self.manipulator = member
        new_raw_data = {
          :_id         => member.data._id,
          :owner_id    => member.data._id,
          :salt        => salt,
          :hashed_code => hashed_code
        }
        
      super(member, new_raw_data).instance_eval  do
        demand :owner_id, :salt, :hashed_code
        set_id( member.data._id )
        result = save_create
        @code = code
        result
      end
    
    end
  
  end # === self
  # ==== Authorizations ====
 
  def allow_to? action, editor
    case action
    when :create
      true
    when :read
      false
    when :update
      false
    when :delete
      editor.data._id == owner!.fetch('_id')
    end
  end

  # ==== Accessors ====
  
  def change_password raw_opts 
    
    if new?
      raise Not_In_Reset, "Can't reset password when account has not been reset."
    end
    
    opts                = Data_Pouch.new(raw_opts, :manipulator, :code, :password, :confirm_password)
    all_values_included = opts.code && opts.password && opts.confirm_password
    raise ArgumentError, "Missing values: #{opts.as_hash.inspect}" if not all_values_included

    if BCrypt::Password.new(data.hashed_code) === (opts.code + data.salt ) 
      results = Member.update( data._id, opts.manipulator, opts.as_hash ) 
      Password_Reset.delete data._id, opts.manipulator
      results
    else
      raise Invalid_Code, "Member: #{data._id}, Code: #{opts.code}"
    end
    
  end


end # === end Password_Reset
