module Clickhoused
  module Columns
    class BoolColumn < Column
      getter values : Array(Bool) = [] of Bool

      def encode(writer : Writer)
      end

      def decode(reader : Reader, rows : UInt64)
        rows.times do
          values << reader.read_bool
        end
      end
    end
  end
end