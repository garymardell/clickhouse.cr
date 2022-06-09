require "./spec_helper"

describe Clickhouse do
  it "works" do
    DB.open("clickhouse://localhost:8123") do |db|
      db.exec("DROP TABLE IF EXISTS everything;")

      db.exec("CREATE TABLE everything (
        int8 Int8,
        int16 Int16,
        int32 Int32,
        int64 Int64,
        int128 Int128,
        int256 Int256,
        uint8 UInt8,
        uint16 UInt16,
        uint32 UInt32,
        uint64 UInt64,
        uint128 UInt128,
        uint256 UInt256,
        float32 Float32,
        float64 Float64
      ) ENGINE = TinyLog")

      values = {
        -1_i8,
        -2_i16,
        -3_i32,
        -4_i64,
        -5_i128,
        -BigInt.new(6),
        7_u8,
        8_u16,
        9_u32,
        10_u64,
        11_u128,
        BigInt.new(12),
        123.45678_f32,
        4567.45642234_f64
      }

      db.exec("INSERT INTO everything (
        int8,
        int16,
        int32,
        int64,
        int128,
        int256,
        uint8,
        uint16,
        uint32,
        uint64,
        uint128,
        uint256,
        float32,
        float64
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", *values)

      result = db.query_all "SELECT
        int8,
        int16,
        int32,
        int64,
        int128,
        int256,
        uint8,
        uint16,
        uint32,
        uint64,
        uint128,
        uint256,
        float32,
        float64
      FROM everything", 0, as: {
        Int8,
        Int16,
        Int32,
        Int64,
        Int128,
        BigInt,
        UInt8,
        UInt16,
        UInt32,
        UInt64,
        UInt128,
        BigInt,
        Float32,
        Float64
      }

      result.size.should eq(1)
      result[0].should eq(values)

      db.exec("DROP TABLE everything;")
    end
  end
end
