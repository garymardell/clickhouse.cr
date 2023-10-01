module Clickhoused
  module Columns
    class UInt16Column < Column
      property values : Array(UInt16)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(UInt16).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_fixed16
        end
      end
    end
  end
end