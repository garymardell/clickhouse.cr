require "uuid"
require "uri/params"

module Clickhouse
  class Statement < ::DB::Statement
    protected def conn
      connection.as(Connection)
    end

    protected def perform_query(args : Enumerable) : ResultSet
      conn = self.conn

      params = URI::Params.build do |form|
        form.add "query", command
      end

      response = conn.http.post("/?#{params}")

      ResultSet.new(self, response)
    rescue IO::Error
      raise DB::ConnectionLost.new(connection)
    end

    protected def perform_exec(args : Enumerable) : ::DB::ExecResult
      result = perform_query(args)
      result.each { }

      ::DB::ExecResult.new(
        rows_affected: 0_i64,
        last_insert_id: 0_i64 # Clickhouse doesn't support this?
      )
    rescue IO::Error
      raise DB::ConnectionLost.new(connection)
    end

    private def quote(string : String)
      String.build do |io|
        io << "\""
        io << string
        io << "\""
      end
    end
  end
end