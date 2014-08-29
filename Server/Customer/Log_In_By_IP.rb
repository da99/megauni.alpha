
class Customer
  class Log_In_By_IP

    TABLE = DB[:customer_bad_log_in_by_ip]

    class << self

      def create_or_read_by_ip ip

        # === Update if old ip
        ip_row = TABLE.
          returning.
          where(" ip = ? AND log_in_at != ? ", ip, Okdoki::Model::PG::UTC_NOW_DATE).
          update(log_in_at: Okdoki::Model::PG::UTC_NOW_DATE).
          first

        if !ip_row
          ip_row = TABLE[:ip=>ip, :log_in_at=>Okdoki::Model::PG::UTC_NOW_DATE]

          if !ip_row
            ip_row = TABLE.
              returning.
              insert(ip: ip).
              first
          end
        end

        o = new(ip_row)

        if o.too_many_bad_logins?
          raise Customer::Too_Many_Bad_Logins.new(Customer.new(), 'Too many bad log-ins for today. Try again tomorrow.')
        end

        o
      end

    end # === class self ===

    attr_reader :data

    def initialize row
      @data = row
    end

    def too_many_bad_logins?
      data[:bad_log_in_count] > 3
    end

    def inc_bad_log_in_count
      self.class::TABLE.
        where(ip: data[:ip]).
        update(" bad_log_in_count = ( bad_log_in_count + 1 ) ")
    end

  end # === class Log_In_By_IP ===
end # === class Customer ===
