require "spec"
require "../src/clickhouse"

Spec.around_each do |example|
  unless example.example.all_tags.includes?("db")
    example.run
    next
  end

  DB.open("clickhouse://127.0.0.1:9000") do |db|
    begin
      db.exec("DROP DATABASE IF EXISTS test SYNC")
      db.exec("CREATE DATABASE test")

      example.run
    ensure
      db.exec("DROP DATABASE IF EXISTS test SYNC")
    end
  end
end

def with_connection
  DB.open("clickhouse://127.0.0.1:9000/test") do |db|
    yield db
  end
end

def consume_until(connection, klass : T.class) forall T
  packet = nil

  until packet.is_a?(T)
    packet = connection.read_packet
  end

  packet
end
