require "uuid"

module Clickhoused
  module Columns
    class UUIDColumn < Column
      property values : Array(UUID) = [] of UUID

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
          values << UUID.new(reader.read(16))
        end
      end
    end
  end
end