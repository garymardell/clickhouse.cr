module Clickhouse
  module CustomSerialization
    abstract def read_state_prefix(reader : Reader)
  end
end