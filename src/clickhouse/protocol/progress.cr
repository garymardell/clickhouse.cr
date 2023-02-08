module Clickhouse
  module Protocol
    struct Progress
      include Message

      property rows : UInt64
      property bytes : UInt64
      property total_rows : UInt64
      property wrote_rows : UInt64
      property wrote_bytes : UInt64
      property with_client : Bool

      def initialize(@rows, @bytes, @total_rows, @wrote_rows, @wrote_bytes, @with_client)
      end

      def encode(buffer : Buffer)
      end
    end
  end
end