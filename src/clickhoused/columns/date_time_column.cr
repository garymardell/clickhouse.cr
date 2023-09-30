module Clickhoused
  module Columns
    class DateTimeColumn < Column
      property values : Array(Time) = [] of Time

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
          values << Time.unix(reader.read_sfixed32)
        end
      end
    end
  end
end