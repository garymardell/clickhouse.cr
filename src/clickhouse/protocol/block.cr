module Clickhouse
  module Protocol
    struct Column
    end

    struct Block
      property names : Array(String)
      property packet : Bytes?
      property columns : Array(Column)

      def initialize(@names = [] of String, @packet = nil, @columns = [] of Column)
      end

      def encode(buffer : Buffer, revision : UInt64)
        encode_header(buffer, revision)
      end

      def encode_header(buffer : Buffer, revision : UInt64)
        if revision > 0
          encode_block_info(buffer)
        end

        rows = 0

        # TODO: Calculate rows

        buffer.write_uint64(columns.size.to_u64)
        buffer.write_uint64(rows.to_u64)
      end

      def encode_block_info(buffer : Buffer)
        buffer.write_uint64(1_u64)
        buffer.write_bool(false)
        buffer.write_uint64(2_u64)
        buffer.write_sfixed32(-1)
        buffer.write_uint64(0_u64)
      end
    end
  end
end
