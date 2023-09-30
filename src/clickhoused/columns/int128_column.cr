module Clickhoused
  module Columns
    class Int128Column < Column
      property values : Array(Int128) = [] of Int128

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
          values << reader.read_sfixed128
        end
      end
    end
  end
end