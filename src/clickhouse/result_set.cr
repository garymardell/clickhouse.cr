require "csv"

module Clickhouse
  class ResultSet < ::DB::ResultSet
    # Currently this is eager loading the whole block, rather than on demand for rows.
    def initialize(statement, @block : Protocol::Block?)
      super(statement)

      @column_index = -1
      @end = false
      @rows_affected = 0_i64
    end

    protected def conn
      statement.as(Statement).conn
    end

    def move_next : Bool
     false
    end

    def column_count : Int32
      0
    end

    def column_name(index : Int32) : String
      ""
    end

    def read
      # @column_index += 1

      # decoder = Decoders.for_name(@types[@column_index])
      # decoder.decode(@csv.row[@column_index])
      ""
    end

    def next_column_index : Int32
      1
    end
  end
end