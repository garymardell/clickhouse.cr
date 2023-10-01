module Clickhoused
  module Columns
    class UInt64Column < Column
      property values : Array(UInt64)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(UInt64).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_fixed64
        end
      end
    end
  end
end