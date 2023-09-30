require "digest"
require "./spec_helper"

def consume_until(connection, klass : T.class) forall T
  packet = nil

  until packet.is_a?(T)
    packet = connection.read_packet
  end

  packet
end

describe Clickhoused do
  it "works" do
    connection = Clickhoused::Connection.new(
      host: "127.0.0.1",
      port: 9000,
      database: "default",
      username: "default",
      password: ""
    )

    connection.send_query("CREATE DATABASE IF NOT EXISTS \"test\"", Clickhoused::QueryOptions.new)
    consume_until(connection, Clickhoused::Packets::EndOfStream)

    connection.send_ping
    consume_until(connection, Clickhoused::Packets::Pong)

    connection.send_query("CREATE TABLE IF NOT EXISTS blobs (version UInt8) ENGINE=MergeTree() ORDER BY version", Clickhoused::QueryOptions.new)
    consume_until(connection, Clickhoused::Packets::EndOfStream)

    connection.send_query("TRUNCATE TABLE blobs", Clickhoused::QueryOptions.new)
    consume_until(connection, Clickhoused::Packets::EndOfStream)

    puts "inserting"
    connection.send_query("INSERT INTO blobs (version) VALUES (1)", Clickhoused::QueryOptions.new)
    consume_until(connection, Clickhoused::Packets::EndOfStream)

    connection.send_query("SELECT * FROM blobs", Clickhoused::QueryOptions.new)
    pp "first packet"
    pp connection.read_packet # Data (empty)
    pp connection.read_packet # Data
    pp connection.read_packet # ProfileInfo
    pp connection.read_packet # Progress
    pp connection.read_packet # ProfileEvents
    pp connection.read_packet # Data (empty)
    pp connection.read_packet # Progress
    pp connection.read_packet # EndOfStream

  end

  # it "works again" do
  #   DB.open("clickhouse://127.0.0.1:9000") do |db|
  #     db.exec("CREATE DATABASE IF NOT EXISTS \"test\"")

  #     db.exec("DROP TABLE blobs");
  #     db.exec("CREATE TABLE IF NOT EXISTS blobs (version UInt64) ENGINE=MergeTree() ORDER BY version")
  #     db.exec("TRUNCATE TABLE blobs")

  #     query = String.build do |io|
  #       io << "INSERT INTO blobs (version) VALUES "

  #       10000.times do |i|
  #         io << "("
  #         io << i
  #         io << ")"
  #         io << ", " unless i == 9999
  #       end
  #     end

  #     100.times do
  #       db.exec(query)
  #     end

  #     # 10000.times do |i|
  #     #   db.exec("INSERT INTO blobs (version) VALUES (#{i})")
  #     # end

  #     db.query("SELECT * FROM blobs ORDER BY version ASC LIMIT 100") do |rs|
  #       rs.each do
  #         pp rs.read(UInt64)
  #       end
  #     end
  #   end
  # end

  it "works datetimes", focus: true do
    DB.open("clickhouse://127.0.0.1:9000") do |db|
      db.exec("CREATE DATABASE IF NOT EXISTS \"test\"")

      db.exec("DROP TABLE blobs");
      db.exec("CREATE TABLE IF NOT EXISTS blobs (version Array(String)) ENGINE=MergeTree() ORDER BY version")
      db.exec("TRUNCATE TABLE blobs")

      query = String.build do |io|
        io << "INSERT INTO blobs (version) VALUES "

        1.times do |i|
          io << "("
          io << "['hello', 'goodbye']"
          io << ")"
          # io << ", " unless i == 1
        end
      end

      1.times do
        db.exec(query)
      end

      # 10000.times do |i|
      #   db.exec("INSERT INTO blobs (version) VALUES (#{i})")
      # end

      db.query("SELECT * FROM blobs ORDER BY version ASC LIMIT 100") do |rs|
        rs.each do
          pp rs.read(Array(String))
        end
      end
    end
  end
end
