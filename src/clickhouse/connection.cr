require "socket"
require "http/client"

module Clickhouse
  class Connection < ::DB::Connection
    protected getter http : HTTP::Client

    def initialize(context)
      super(context)

      uri = context.uri
      uri.scheme = context.uri.scheme == "clickhouse" ? "http" : "https"

      @http = HTTP::Client.new(uri)
      @http.basic_auth(uri.user, uri.password) if uri.user && uri.password
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
        @http.close
      rescue
      end
    end
  end
end