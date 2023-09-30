module Clickhoused
  module Columns
    class StringColumn < Column
      property values : Array(String) = [] of String

      def rows : Int32
        values.size
      end

      def get(row : Int32)
        values[row]
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader, rows : UInt64)
        rows.times do
          values << reader.read_string.to_s
        end
      end
    end
  end
end