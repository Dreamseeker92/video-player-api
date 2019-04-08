require_relative '../../../lib/adapter'

class RedisAdapter < ApiVideos::Adapter
  attr_reader :db

  def initialize
    @db = Redis.new
    db.set("#{table_name}_sequence", 0)
  end

  def create(params = {})
    id = increment_sequence
    db.hmset("#{table_name}:#{id}", params.flatten)
  end

  def find_by_id(id)
    db.hgetall("#{table_name}:#{id}")
  end

  def delete_by_id(id)
    keys = find_by_id(id).keys
    db.pipelined do
      keys.each { |key| db.hdel("#{table_name}:#{id}", key)}
    end
  end

  def all
    id_pool_members.map(&method(:find_by_id))
  end

  private

  def increment_sequence
    db.incr("#{table_name}_sequence")
  end

  def id_pool_members
    db.smembers("#{table_name}_id_pool")
  end

  def add_to_id_pool(num)
    db.sadd("#{table_name}_id_pool", num)
  end

  def remove_from_id_pool(num)
    db.srem("#{table_name}_id_pool", num)
  end

end