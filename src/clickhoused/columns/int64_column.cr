module Clickhoused
  module Columns
    class Int64Column < Column
      property values : Array(Int64) = [] of Int64

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
          values << reader.read_sfixed64
        end
      end
    end
  end
end