module Clickhoused
  module Columns
    class StringColumn < Column
      property values : Array(String)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(String).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read_string.to_s
        end
      end
    end
  end
end