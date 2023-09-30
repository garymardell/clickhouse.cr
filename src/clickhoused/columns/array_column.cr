require "../column"

module Clickhoused
  module Columns
    class ArrayColumn < Column
      getter values : Array(Column) = [] of Column

      def get(row : Int32)
        values[row].values
      end

      def encode(writer : Writer)
      end

      def decode(reader : Reader, rows : UInt64)
        rows.times do
          wrapped_type = column_type.new(name, type, timezone)
          wrapped_type.decode(reader, reader.read_fixed64)

          values << wrapped_type
        end
      end

      def column_type : Column.class
        if wrapped_name = type.match(/^Array\((.*)\)/)
          Column.for_type(wrapped_name[1].not_nil!).not_nil!
        else
          raise "Unsupported column type"
        end
      end
    end
  end
end