module Clickhoused
  module Columns
    class Float32Column < Column
      property values : Array(Float32) = [] of Float32

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
          values << reader.read_float
        end
      end
    end
  end
end