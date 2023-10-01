module Clickhoused
  module Columns
    class Float64Column < Column
      property values : Array(Float64)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Float64).new(rows)
      end

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