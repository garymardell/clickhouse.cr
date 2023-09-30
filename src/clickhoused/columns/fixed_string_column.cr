module Clickhoused
  module Columns
    class FixedStringColumn < Column
      property values : Array(Bytes) = [] of Bytes

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
          values << reader.read(bytelength)
        end
      end

      private def bytelength
        if match = type.match(/FixedString\((\d+)\)/)
          match[1].to_i
        else
          0
        end
      end
    end
  end
end