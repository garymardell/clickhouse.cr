require "../column"

module Clickhoused
  module Columns
    class ArrayColumn(C) < Column
      property values : Array(C) = [] of C

      def rows : Int32
        values.size
      end

      def get(row : Int32)
        values[row].values
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader, rows : UInt64)
        rows.times do
          wrapped_type = C.new(name, column_type, timezone)
          wrapped_type.decode(reader, reader.read_fixed64)

          values << wrapped_type
        end
      end

      def column_type
        column_type = if wrapped_name = type.match(/^Array\((.*)\)/)
          wrapped_name[1]
        end

        column_type || ""
      end
    end
  end
end