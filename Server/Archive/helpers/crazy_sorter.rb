##########################################################
# A collection of functions to sort Arrays with
# various types.
##########################################################
class CrazySorter
  #
  # 
  #  
  def self.sort_it_like_excel(a, &blok)
    # First, take out the exact numerals from column
    
    nums      = a.select { |raw_i|
                                    i = blok.nil? ? raw_i : blok.call(raw_i) 
                                    begin
                                      Float( i )
                                    rescue
                                      false
                                    end
                                  }
    strs        = a - nums

    # Then sort the strings: http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/215370
    sorted_strs = strs.sort_by { |raw_i|
                                                i = blok.nil? ? raw_i :  blok.call(raw_i)
                                                [ i.to_s.upcase, i.to_s]
                                              }

    # Then sort the numerals
    sorted_nums = nums.sort { | raw_i, raw_j| 
                                                i = blok.nil? ? raw_i  : blok.call(raw_i)
                                                j = blok.nil? ? raw_j : blok.call(raw_j)
                                                i.to_f <=> j.to_f
                                              }

    # Then combine them with numerals first.
    sorted = sorted_nums + sorted_strs
    
    
    sorted
  end
  
end # === CrazySorter

