require "./spec_helper"

describe Clickhouse do
  it "works" do
    DB.open("clickhouse://127.0.0.1:8123") do |db|
      100.times do
        db.query("SELECT tenant_id FROM spans LIMIT 10") do |rs|
          rs.each do
            rs.read(String)
          end
        end

        sleep 1
      end
    end
  end
end
