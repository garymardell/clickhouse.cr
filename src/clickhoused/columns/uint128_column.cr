module Clickhoused
  module Columns
    class UInt128Column < Column
      property values : Array(UInt128)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(UInt128).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_fixed128
        end
      end
    end
  end
end