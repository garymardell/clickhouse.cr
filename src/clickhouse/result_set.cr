module Clickhouse
  class ResultSet < ::DB::ResultSet
    def initialize(statement : Statement, @blocks : Array(Clickhoused::Packets::Data))
      super(statement)

      @block_index = 0
      @block_row_index = -1

      @row_index = -1
      @column_index = -1
    end

    def move_next : Bool
      if @row_index < rows - 1
        @row_index += 1
        @block_row_index += 1
        @column_index = -1

        if @block_row_index >= current_block.rows
          move_to_next_block
        end

        true
      else
        false
      end
    end

    private def current_block
      @blocks[@block_index]
    end

    private def move_to_next_block
      @block_index += 1
      @block_row_index = -1
    end

    private def rows
      @blocks.sum(&.rows)
    end

    def column_count : Int32
      current_block.columns.size || 0
    end

    def column_name(index : Int32) : String
      column = current_block.columns[@column_index]
      column.name
    end

    def read
      column = current_block.columns[@column_index]
      column.get(@block_row_index)
    end

    def next_column_index : Int32
      @column_index += 1 if @column_index < column_count
      @column_index
    end
  end
end