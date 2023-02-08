require "./spec_helper"

describe Clickhouse do
  it "works" do
    DB.open("clickhouse://127.0.0.1:9000") do |db|
      db.exec("SELECT * FROM sales")
    end
  end
end
