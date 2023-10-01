module Clickhoused
  module Columns
    class FixedStringColumn < Column
      property values : Array(Bytes)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Bytes).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << reader.read(bytelength)
        end
      end

      private def bytelength
        if match = type.match(/FixedString\((\d+)\)/)
          match[1].to_i
        else
          0
        end
      end
    end
  end
end