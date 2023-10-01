require "../column"

module Clickhoused
  module Columns
    class ArrayColumn < Column
      getter values : Array(Column)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Column).new(rows)
      end

      def get(row : Int32)
        values[row].values
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader, rows : UInt64)
        offsets = [] of UInt64

        rows.times do
          offsets << reader.read_fixed64
        end

        offsets.each_with_index do |offset, index|
          difference = if index > 0
            offsets[index - 1]
          else
            0
          end

          rows = offset - difference

          wrapped_type = column_type.new(name, type, timezone, rows)
          wrapped_type.decode(reader, rows)

          values << wrapped_type
        end
      end

      def column_type : Column.class
        if wrapped_name = type.match(/^Array\((.*)\)/)
          Column.for_type(wrapped_name[1].not_nil!).not_nil!
        else
          raise "Unsupported column type"
        end
      end
    end
  end
end