module Clickhoused
  module Columns
    class UInt64Column < Column
      property values : Array(UInt64) = [] of UInt64

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
          values << reader.read_fixed64
        end
      end
    end
  end
end