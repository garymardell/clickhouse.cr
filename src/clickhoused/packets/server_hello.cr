require "../server_packet"
require "../version"

module Clickhoused
  module Packets
    struct ServerHello < ServerPacket
      property name : String
      property display_name : String?
      property revision : UInt64
      property version : Version
      property timezone : Time::Location

      def initialize(@name, @display_name, @revision, @version, @timezone)
      end

      def self.decode(reader : Reader)
        name = reader.read_string.not_nil!
        display_name = nil

        major = reader.read_uint64.not_nil!
        minor = reader.read_uint64.not_nil!
        revision = reader.read_uint64.not_nil!

        timezone = if revision >= DBMS_MIN_REVISION_WITH_SERVER_TIMEZONE
          timezone_name = reader.read_string.not_nil!

          Time::Location.load(timezone_name)
        else
          Time::Location.local
        end

        if revision >= DBMS_MIN_REVISION_WITH_SERVER_DISPLAY_NAME
          display_name = reader.read_string
        end

        patch = if revision >= DBMS_MIN_REVISION_WITH_VERSION_PATCH
          reader.read_uint64.not_nil!
        else
          revision
        end

        ServerHello.new(
          name,
          display_name,
          revision,
          Version.new(major, minor, patch),
          timezone
        )
      end
    end
  end
end