module Clickhoused
  module Columns
    class Float64Column < Column
      property values : Array(Float64) = [] of Float64

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
          values << reader.read_double
        end
      end
    end
  end
end