module Clickhoused
  module Columns
    class BoolColumn < Column
      getter values : Array(Bool)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Bool).new(rows)
      end

      def initialize_values
        @values = Array(Bool).new(rows)
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader, rows : UInt64)
        rows.times do
          values << reader.read_bool
        end
      end
    end
  end
end