module Clickhoused
  module Columns
    class Int32Column < Column
      property values : Array(Int32) = [] of Int32

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
          values << reader.read_sfixed32
        end
      end
    end
  end
end