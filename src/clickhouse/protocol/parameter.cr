module Clickhouse
  module Protocol
    struct Parameter
      property key : String
      property value : String

      def initialize(@key, @value)
      end

      def encode(buffer : Buffer, revision : UInt64)
        buffer.write_string(key)
        buffer.write_uint64(2_u64)
        buffer.write_string("'#{value.gsub("'", "\\'")}'")
      end
    end
  end
end
