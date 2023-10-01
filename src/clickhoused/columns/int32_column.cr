module Clickhoused
  module Columns
    class Int32Column < Column
      property values : Array(Int32)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Int32).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_sfixed32
        end
      end
    end
  end
end