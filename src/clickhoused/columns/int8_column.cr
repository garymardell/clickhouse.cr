module Clickhoused
  module Columns
    class Int8Column < Column
      property values : Array(Int8)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Int8).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_sfixed8
        end
      end
    end
  end
end