module Clickhoused
  module Columns
    class Int64Column < Column
      property values : Array(Int64)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Int64).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_sfixed64
        end
      end
    end
  end
end