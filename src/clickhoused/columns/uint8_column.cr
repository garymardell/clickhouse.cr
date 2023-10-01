module Clickhoused
  module Columns
    class UInt8Column < Column
      property values : Array(UInt8)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(UInt8).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_fixed8
        end
      end
    end
  end
end