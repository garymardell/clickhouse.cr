module Clickhouse
  module Protocol
    struct Block
      property names : Array(String)
      property packet : UInt8?
      property columns : Array(Column)
      property timezone : Time::Location?

      def initialize(@names = [] of String, @packet = nil, @columns = [] of Column, @timezone = nil)
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

      def self.decode(reader : Reader, revision : UInt64, packet : UInt8, timezone : Time::Location)
        if revision > 0
          self.decode_block_info(reader)
        end

        cols = reader.read_uint64.not_nil!
        rows = reader.read_uint64.not_nil!

        if rows > 1_000_000_000
          raise Error.new("More than 1 billion rows returned")
        end

        names = [] of String
        columns = [] of Column

        cols.times do
          name = reader.read_string.not_nil!
          type = reader.read_string.not_nil!

          column_class = Column.for_type(type)

          unless column_class
            raise Error.new("unsupported column type #{type}")
          end

          column = column_class.new(name, timezone)

          if revision >= DBMS_MIN_REVISION_WITH_CUSTOM_SERIALIZATION
            if has_custom = reader.read_bool.not_nil!
              raise Error.new("custom serialization for column #{name}. not supported")
            end
          end

          if rows != 0
            if column.is_a?(CustomSerialization)
              column.read_state_prefix(reader)
            end

            column.decode(reader, rows)

            names << name
            columns << column
          end
        end

        new(names, packet, columns, timezone)
      end

      def self.decode_block_info(reader : Reader)
        reader.read_uint64
        reader.read_bool
        reader.read_uint64
        reader.read_sfixed32
        reader.read_uint64
      end
    end
  end
end
