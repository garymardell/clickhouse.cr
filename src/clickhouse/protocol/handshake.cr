module Clickhouse
  module Protocol
    ClientName = "Crystal Driver"

    ClientVersionMajor       = 2_u8
    ClientVersionMinor       = 5_u8
    ClientVersionPatch       = 0_u8
    ClientTCPProtocolVersion = DBMS_TCP_PROTOCOL_VERSION

    struct Version
      include Message

      property major : UInt64
      property minor : UInt64
      property patch : UInt64

      def initialize(@major, @minor, @patch)
      end

      def encode(buffer : Buffer)
      end
    end

    struct ClientHandshake
      include Message

      property name : String
      property revision : UInt64

      def initialize(@name, @revision)
      end

      def encode(buffer : Buffer)
        buffer.write_string(name)
        buffer.write_uint64(2u64)
        buffer.write_uint64(5u64)
        buffer.write_uint64(revision)
      end
    end

    struct ServerHandshake
      include Message

      property name : String
      property display_name : String?
      property revision : UInt64
      property version : Version
      property timezone : Time::Location

      def initialize(@name, @display_name, @revision, @version, @timezone)
      end

      def encode(buffer : Buffer)
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

        ServerHandshake.new(
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