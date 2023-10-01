module Clickhoused
  module Columns
    class UInt32Column < Column
      property values : Array(UInt32)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(UInt32).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_fixed32
        end
      end
    end
  end
end