module Clickhouse
  class Connection < ::DB::Connection
    protected getter connection : Clickhoused::Connection

    def initialize(context)
      super(context)

      host = context.uri.hostname || raise "no host provided"
      port = context.uri.port || 9000
      database = context.uri.path.try &.lstrip('/') || "default"

      @connection = Clickhoused::Connection.new(
        host: host,
        port: port,
        database: database,
        username: context.uri.user || "default",
        password: context.uri.password || ""
      )
    end

    def build_prepared_statement(query) : Statement
      Statement.new(self, query)
    end

    def build_unprepared_statement(query) : Statement
      Statement.new(self, query)
    end

    def begin_transaction : ::DB::Transaction
      raise ::DB::Error.new("Transactions are not supported")
    end

    protected def do_close
      super

      begin
        @connection.close
      rescue
      end
    end
  end
end