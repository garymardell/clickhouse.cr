require "http/client"

module Clickhouse
  class Connection < ::DB::Connection
    protected getter http : HTTP::Client

    def initialize(context)
      super(context)

      uri = context.uri.dup
      uri.scheme = context.uri.scheme == "clickhouse" ? "http" : "https"

      @http = build_http(uri)
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

    private def build_http(uri)
      HTTP::Client.new(uri).tap do |http|
        http.basic_auth(uri.user, uri.password) if uri.user && uri.password
      end
    end
  end
end