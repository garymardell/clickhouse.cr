module Clickhouse
  module Protocol
    struct Version
      include Message

      property major : UInt64
      property minor : UInt64
      property patch : UInt64

      def initialize(@major, @minor, @patch)
      end

      def encode(encoder : Encoder)
      end
    end

    struct ClientHandshake
      include Message

      def encode(encoder : Encoder)
      end
    end

    struct ServerHandshake
      include Message

      property name : String
      property display_name : String
      property revision : UInt64
      property version : Version
      property timezone : Time::Location

      def initialize(@name, @display_name, @revision, @version, @timezone)
      end

      def encode(encoder : Encoder)
      end
    end
  end
end