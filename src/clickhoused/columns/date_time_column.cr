module Clickhoused
  module Columns
    class DateTimeColumn < Column
      property values : Array(Time)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Time).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        rows.times do
          values << Time.unix(reader.read_sfixed32)
        end
      end
    end
  end
end