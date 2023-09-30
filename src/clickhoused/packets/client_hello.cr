require "../client_packet"
require "../version"

module Clickhoused
  module Packets
    ClientName = "Crystal Driver"

    class ClientHello < ClientPacket
      property name : String
      property version : Version
      property protocol_version : UInt64

      def initialize(@name, @version)
        @protocol_version = DBMS_TCP_PROTOCOL_VERSION
      end

      def encode(writer : Writer)
        writer.write_string(name)
        writer.write_uint64(version.major)
        writer.write_uint64(version.minor)
        writer.write_uint64(protocol_version)
      end
    end
  end
end