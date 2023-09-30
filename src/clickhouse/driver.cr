module Clickhouse
  class Driver < ::DB::Driver
    def build_connection(context : ::DB::ConnectionContext) : Connection
      Connection.new(context)
    end
  end
end

DB.register_driver "clickhouse", Clickhouse::Driver
