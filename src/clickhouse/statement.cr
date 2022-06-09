module Clickhouse
  class Statement < ::DB::Statement
    protected def conn
      connection.as(Connection).connection
    end

    protected def perform_query(args : Enumerable) : ResultSet
      conn = self.conn

      headers = HTTP::Headers.new
      headers["X-ClickHouse-Format"] = "CSVWithNamesAndTypes"

      bound_command = bind(command, args)

      response = conn.post(path: "/", body: bound_command, headers: headers)

      unless response.status == HTTP::Status::OK
        raise ::DB::Error.new(response.body)
      end

      ResultSet.new(self, response)
    rescue IO::Error
      raise DB::ConnectionLost.new(connection)
    end

    protected def perform_exec(args : Enumerable) : ::DB::ExecResult
      result = perform_query(args)
      result.each { }

      ::DB::ExecResult.new(
        rows_affected: 0_i64,
        last_insert_id: 0_i64 # postgres doesn't support this
      )
    rescue IO::Error
      raise DB::ConnectionLost.new(connection)
    end

    private def bind(command, args)
      # "INSERT INTO micrate_db_version (version_id, is_applied) VALUES (?, ?);
      regex = /[?]/

      index = 0
      command.gsub(pattern: /[?]/) do |_|
        value = format(args[index])
        index += 1
        value
      end
    end

    private def format(arg)
      case arg
      when Time
        "toDateTime(#{arg.to_unix})"
      when Bool
        arg ? "true" : "false"
      when Int8, Int16, Int32, Int64, Int128, BigInt
        arg.to_s
      when UInt8, UInt16, UInt32, UInt64, UInt128
        arg.to_s
      when Float32, Float64
        arg.to_s
      when String
        quote(arg)
      when Nil
        "NULL"
      else
        quote("")
      end
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