require "uuid"

module Clickhoused
  module Columns
    class UUIDColumn < Column
      property values : Array(UUID)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(UUID).new(rows)
      end

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