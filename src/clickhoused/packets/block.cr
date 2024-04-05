require "../server_packet"
require "../column"

module Clickhoused
  module Packets
    abstract struct Block < ServerPacket
      property names : Array(String)
      property packet : UInt8?
      property columns : Array(Column)
      property timezone : Time::Location?

      def initialize(@names = [] of String, @packet = nil, @columns = [] of Column, @timezone = nil)
      end

      def encode(writer : Writer, revision : UInt64)
        encode_header(writer, revision)
      end

      def encode_header(writer : Writer, revision : UInt64)
        if revision > 0
          encode_block_info(writer)
        end

        rows = 0

        # if columns.size > 0
        #   rows = columns.first.rows

        #   columns.each_with_index do |column, index|
        #     next if index == 0

        #     if rows != column.rows
        #       raise "mismatch in row length"
        #     end
        #   end
        # end

        writer.write_uint64(columns.size.to_u64)
        writer.write_uint64(rows.to_u64)
      end

      def encode_block_info(writer : Writer)
        writer.write_uint64(1_u64)
        writer.write_bool(false)
        writer.write_uint64(2_u64)
        writer.write_sfixed32(-1)
        writer.write_uint64(0_u64)
      end

      def rows
        columns.first?.try &.rows || 0
      end

      def self.decode(reader : Reader, revision : UInt64, packet : UInt8, timezone : Time::Location)
        if revision > 0
          self.decode_block_info(reader)
        end

        cols = reader.read_uint64.not_nil!
        rows = reader.read_uint64.not_nil!

        if rows > 1_000_000_000
          raise "More than 1 billion rows returned"
        end

        names = [] of String
        columns = [] of Column

        cols.times do
          name = reader.read_string.not_nil!
          type = reader.read_string.not_nil!

          column_class = Column.for_type(type)

          unless column_class
            raise "unsupported column type #{type}"
          end

          column = column_class.new(name, type, timezone, rows)

          if revision >= DBMS_MIN_REVISION_WITH_CUSTOM_SERIALIZATION
            if has_custom = reader.read_bool.not_nil!
              raise "custom serialization for column #{name}. not supported"
            end
          end

          if rows != 0
            # if column.is_a?(CustomSerialization)
            #   column.read_state_prefix(reader)
            # end

            column.decode(reader)

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
