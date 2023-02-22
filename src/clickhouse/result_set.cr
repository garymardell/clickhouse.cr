require "csv"
require "json"

module Clickhouse
  class ResultSet < ::DB::ResultSet
    property rows : Array(Array(JSON::Any::Type))
    property columns : Array(String) = [] of String
    property types : Array(String) = [] of String

    # Currently this is eager loading the whole block, rather than on demand for rows.
    def initialize(statement, response)
      super(statement)

      @rows = response.body.split("\n").reduce([] of Array(JSON::Any::Type)) do |memo, compact|
        memo << Array(JSON::Any::Type).from_json(compact) unless compact.blank?
        memo
      end

      if @rows.size > 0
        @columns = @rows.shift.map(&.to_s)
        @types = @rows.shift.map(&.to_s)
      end

      @row = -1
      @column_index = -1
      @end = false
      @rows_affected = 0_i64
    end

    protected def conn
      statement.as(Statement).conn
    end

    def move_next : Bool
      if @column_index <= column_count - 1
        @column_index = -1
      end

      if @row + 1 < @rows.size
        @row += 1
        true
      else
        false
      end
    end

    def column_count : Int32
      @columns.size
    end

    def column_name(index : Int32) : String
      @columns[index].to_s
    end

    def read
      @column_index += 1

      type = @types[@column_index].to_s

      @rows[@row][@column_index]
    end

    def next_column_index : Int32
      @column_index
    end
  end
end