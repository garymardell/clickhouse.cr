module Clickhoused
  class ArrayColumn
    getter name : String
    getter type : String
    getter timezone : Time::Location
    getter values : Array(Column | ArrayColumn) = [] of Column | ArrayColumn

    def initialize(@name : String, @type : String, @timezone : Time::Location)
    end

    def rows : Int32
      values.size
    end

    def get(row : Int32)
      values[row].values
    end

    def encode(writer : Writer, revision : UInt64)
    end

    def decode(reader : Reader, rows : UInt64)
      rows.times do
        wrapped_type = column_type.new(name, type, timezone)
        wrapped_type.decode(reader, reader.read_fixed64)

        values << wrapped_type
      end
    end

    def column_type : Column.class | ArrayColumn.class
      if wrapped_name = type.match(/^Array\((.*)\)/)
        Column.for_type(wrapped_name[1].not_nil!).not_nil!
      else
        raise "Unsupported column type"
      end
    end
  end
end