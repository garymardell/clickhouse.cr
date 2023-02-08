module Clickhouse
  module Protocol
    struct Setting
      alias ValueType = Time | Bool | Int8 | Int16 | Int32 | Int128 | BigInt | UInt8 | UInt16 | UInt32 | UInt64 | UInt128 | Float32 | Float64 | String | Nil

      property key : String
      property value : ValueType

      def initialize(@key, @value)
      end

      def encode(buffer : Buffer, revision : UInt64)
        buffer.write_string(key)
        buffer.write_bool(true) # is_important
        buffer.write_string(value.to_s)
      end
    end
  end
end
