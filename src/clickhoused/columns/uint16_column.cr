module Clickhoused
  module Columns
    class UInt16Column < Column
      property values : Array(UInt16) = [] of UInt16

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
          values << reader.read_fixed16
        end
      end
    end
  end
end