require "http"

module Clickhouse
  class Connection < ::DB::Connection
    protected getter connection : HTTP::Client

    def initialize(context)
      super

      # Build HTTP connection from clickhouse uri
      uri = context.uri.dup
      uri.scheme = context.uri.scheme === "clickhouse" ? "http" : "https"

      @connection = HTTP::Client.new(uri)
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