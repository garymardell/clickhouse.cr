module Clickhoused
  module Columns
    class Int128Column < Column
      property values : Array(Int128)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Int128).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_sfixed128
        end
      end
    end
  end
end