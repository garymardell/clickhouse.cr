require "./spec_helper"

describe Clickhouse do
  it "works" do
    DB.open("clickhouse://127.0.0.1:8123") do |db|
      db.exec("DROP TABLE IF EXISTS sales")

      sql = <<-SQL
        CREATE TABLE sales (
          id UUID NOT NULL,
          customer_id UInt64 NOT NULL,
          amount Decimal(21, 3) NOT NULL,
        ) ENGINE = MergeTree()
        ORDER BY (customer_id, id)
        PRIMARY KEY (customer_id, id)
      SQL

      db.exec(sql)

      puts "inserting records"

      1.times do
        values = String.build do |io|
          5.times do |i|
            io << "(generateUUIDv4(), 123456, 45.56)"
            io << "," unless i % 9_999 == 0
          end
        end

        db.exec("INSERT INTO sales VALUES #{values}")
      end

      db.query("SELECT * FROM sales") do |rs|
        rs.each do
          puts rs.read(String)
          puts rs.read(UInt64)
          puts rs.read(BigDecimal)
        end
      end
    end
  end
end
