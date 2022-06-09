module Clickhouse
  module Protocol
    struct Block
      include Message

      property names : Array(String)
      property packet : Bytes
      # property columns : Array(Column)

      def initialize(@names, @packet)
      end

      def encode(encoder : Encoder)
      end
    end
  end
end