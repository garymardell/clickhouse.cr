module Clickhoused
  module Columns
    class Float32Column < Column
      property values : Array(Float32)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Float32).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_float
        end
      end
    end
  end
end