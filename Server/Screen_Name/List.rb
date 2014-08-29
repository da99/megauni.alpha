
class Screen_Name

  class List # === Not called an Array to avoid confusion.

    include Okdoki::Model::List

    def initialize var = nil
      @customer = nil
      @list     = nil

      case var
      when Customer
        @customer = var
      when Array
        @list = var
      end
    end # === def initialize

    def include? unknown
      name = if unknown.is_a? String
        unknown
      else
        unknown.data[:screen_name]
      end

      !!list.detect { |sn| sn.is? name }
    end

    def list
      @list ||= begin
                  Screen_Name.read_by_customer(@customer)
                end
    end

    def [] raw_name
      list.detect { |sn| sn.is? raw_name }
    end

    def screen_names
      pluck :screen_name
    end

    def ids
      pluck :id
    end

  end # === class List ===

end # === class Screen_Name ===
