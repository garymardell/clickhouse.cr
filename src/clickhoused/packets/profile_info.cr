require "../server_packet"
require "../version"

module Clickhoused
  module Packets
    class ProfileInfo < ServerPacket
      property rows : UInt64
      property blocks : UInt64
      property bytes : UInt64
      property applied_limit : Bool
      property rows_before_limit : UInt64
      property calculated_rows_before_limit : Bool

      def initialize(@rows, @blocks, @bytes, @applied_limit, @rows_before_limit, @calculated_rows_before_limit)
      end

      def self.decode(reader : Reader)
        rows = reader.read_uint64.not_nil!
        blocks = reader.read_uint64.not_nil!
        bytes = reader.read_uint64.not_nil!
        applied_limit = reader.read_bool.not_nil!
        rows_before_limit = reader.read_uint64.not_nil!
        calculated_rows_before_limit = reader.read_bool.not_nil!

        new(
          rows,
          blocks,
          bytes,
          applied_limit,
          rows_before_limit,
          calculated_rows_before_limit
        )
      end
    end
  end
end