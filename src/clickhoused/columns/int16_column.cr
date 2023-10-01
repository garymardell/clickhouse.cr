module Clickhoused
  module Columns
    class Int16Column < Column
      property values : Array(Int16)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Int16).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_sfixed16
        end
      end
    end
  end
end