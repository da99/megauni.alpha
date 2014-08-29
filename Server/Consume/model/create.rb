
require './Server/File_Name/model'

class Consume

  class << self

    def create consumer, type, producer
      r = new
      r.create(
        :class_id   => File_Name.read(type.to_s).id,
        :author_id => consumer.id,
        :pub_id    => producer.id,
        :pub_class_id => File_Name.read(producer.class.to_s).id,
        :consumer_id => consumer.id,
        :consumer_class_id => File_Name.read(consumer.class.to_s).id,
      )
    end

  end # === class self ===

  def create raw
    data = raw

    begin

      rec = TABLE.
        returning.
        insert(data).
        first

    rescue Sequel::UniqueConstraintViolation => e
      raise e unless e.message['unique constraint "consume_unique_idx"']
      rec = TABLE.where(data).first
    end

    @data = rec
    self
  end # === def create

end # === class Consume create ===





