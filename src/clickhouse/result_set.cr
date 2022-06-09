require "csv"

module Clickhouse
  class ResultSet < ::DB::ResultSet
    def initialize(statement, @response : HTTP::Client::Response)
      super(statement)

      @csv = CSV.new(@response.body, headers: true)
      @types = [] of String

      begin
        @csv.next
        @types = @csv.row
      rescue CSV::Error
      end

      @column_index = -1
    end

    protected def conn
      statement.as(Statement).conn
    end

    def move_next : Bool
      @column = -1
      @csv.next
    end

    def column_count : Int32
      @csv.headers.size
    end

    def column_name(index : Int32) : String
      @csv.headers[index]
    end

    def read
      @column_index += 1

      decoder = Decoders.for_name(@types[@column_index])
      decoder.decode(@csv.row[@column_index])
    end

    def next_column_index : Int32
      @column_index
    end
  end
end