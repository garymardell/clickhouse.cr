module Clickhoused
  alias Types = Columns::StringColumn

  abstract class Column
    getter name : String
    getter type : String
    getter timezone : Time::Location

    def initialize(@name : String, @type : String, @timezone : Time::Location)
    end

    def encode(writer : Writer, revision : UInt64)
      writer.write_string(name)
      writer.write_string(type)

      if revision >= DBMS_MIN_REVISION_WITH_CUSTOM_SERIALIZATION
        writer.write_bool(false)
      end

      encode(writer)
    end

    abstract def encode(writer : Writer)
    abstract def decode(reader : Reader, rows : UInt64)

    def rows : Int32
      values.size
    end

    def get(row : Int32)
      values[row]
    end

    def self.for_type(type : String)
      case type
      when "UInt8"
        Columns::UInt8Column
      when "UInt16"
        Columns::UInt16Column
      when "UInt32"
        Columns::UInt32Column
      when "UInt64"
        Columns::UInt64Column
      when "UInt128"
        Columns::UInt128Column
      when "Int8"
        Columns::Int8Column
      when "Int16"
        Columns::Int16Column
      when "Int32"
        Columns::Int32Column
      when "Int64"
        Columns::Int64Column
      when "Int128"
        Columns::Int128Column
      when "Float32"
        Columns::Float32Column
      when "Float64"
        Columns::Float64Column
      when "String"
        Columns::StringColumn
      when "Bool"
        Columns::BoolColumn
      when "DateTime"
        Columns::DateTimeColumn
      when "UUID"
        Columns::UUIDColumn
      when /^FixedString/
        Columns::FixedStringColumn
      when /^Enum8/
        Columns::Enum8Column
      when /^Array/
        Columns::ArrayColumn
      end
    end
  end
end

require "./columns/*"