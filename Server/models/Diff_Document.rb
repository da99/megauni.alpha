
require 'differ'

module Mongo_Dsl::Differ_To_Document
  def to_document
    raw_array.map { |change|
      case change
      when String
        change
      when Differ::Change
        [change.delete, change.insert] 
      else
        raise ArgumentError, "Unknown class: #{change.class}"
      end
    }
  end
end # === module 

module Mongo_Dsl::Diff_Document

  def diff_document new_doc
    raise "Invalid type: #{self.class}" unless self.is_a?(Hash)
    meta = {} 
    new_doc.each { |k, v|
      orig = self[k]
      diff_type = (orig.is_a?(String) && v.is_a?(String) && :String) ||
                  ( !orig && v && :changed ) ||
                  ( orig && !v && :changed ) ||
                  ( (orig.is_a?(Numeric) || v.is_a?(Numeric)) && :changed ) ||
                  (v.is_a?(Array) && :Array) ||
                  v
      
      case diff_type
      when :String
        differ = Differ.diff_by_word(v, self[k])
        differ.extend Mongo_Dsl::Differ_To_Document
        meta[k] = differ.to_document

      when :Array
        o_arr = self[k] || []
        n_arr = v || []
        meta[k] = []

        insert = n_arr - o_arr
        delete = o_arr - n_arr

        if not insert.empty?
          meta[k] << ['+', insert]
        end

        if not delete.empty?
          meta[k] << ['-', delete]
        end
          
      when :changed
        meta[k] = ['-+', orig, v]
        
      else
        raise ArgumentError, "Unknown class for diff-ing: #{orig.inspect}, #{v.inspect}"
      end
    }
    meta
  end
  
end # === module
