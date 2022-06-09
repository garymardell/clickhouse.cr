module Clickhouse
  module Message
    abstract def encode(encoder : Encoder)
  end
end

require "./protocol/*"
