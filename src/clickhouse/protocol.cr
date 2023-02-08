module Clickhouse
  module Message
    abstract def encode(buffer : Buffer)
  end
end

require "./protocol/*"
