require "../column"

module Clickhoused
  module Columns
    class NullableColumn < Column
      getter values : Array(Column | Nil)

      def initialize(@name : String, @type : String, @timezone : Time::Location, @rows : UInt64 = 0)
        @values = Array(Column | Nil).new(rows)
      end

      def get(row : Int32)
        values[row].try &.values.first
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader)
        nulls = [] of Bool

        rows.times do
          nulls << reader.read_bool
        end

        rows.times do |row|
          wrapped_type = column_type.new(name, type, timezone, 1u64)
          wrapped_type.decode(reader)

          if nulls[row]
            values << nil
          else
            values << wrapped_type
          end
        end
      end

      def column_type : Column.class
        if wrapped_name = type.match(/^Nullable\((.*)\)/)
          Column.for_type(wrapped_name[1].not_nil!).not_nil!
        else
          raise "Unsupported column type"
        end
      end
    end
  end
end