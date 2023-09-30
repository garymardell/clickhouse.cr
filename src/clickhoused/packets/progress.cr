require "../server_packet"

module Clickhoused
  module Packets
    class Progress < ServerPacket
      property rows : UInt64
      property bytes : UInt64
      property total_rows : UInt64
      property wrote_rows : UInt64?
      property wrote_bytes : UInt64?
      property with_client : Bool
      property elapsed : Time::Span?

      def initialize(@rows, @bytes, @total_rows, @wrote_rows = nil, @wrote_bytes = nil, @with_client = false, @elapsed = nil)
      end

      def encode(buffer : Buffer)
      end

      def self.decode(reader : Reader, revision : UInt64)
        rows = reader.read_uint64.not_nil!
        bytes = reader.read_uint64.not_nil!
        total_rows = reader.read_uint64.not_nil!

        with_client = false
        wrote_rows = nil
        wrote_bytes = nil

        if revision >= DBMS_MIN_REVISION_WITH_CLIENT_WRITE_INFO
          with_client = true

          wrote_rows = reader.read_uint64.not_nil!
          wrote_bytes = reader.read_uint64.not_nil!
        end

        elapsed = nil
        if revision >= DBMS_MIN_PROTOCOL_VERSION_WITH_SERVER_QUERY_TIME_IN_PROGRES
          nanoseconds = reader.read_uint64.not_nil!
          elapsed = Time::Span.new(nanoseconds: nanoseconds)
        end

        new(rows, bytes, total_rows, wrote_rows, wrote_bytes, with_client, elapsed)
      end
    end
  end
end