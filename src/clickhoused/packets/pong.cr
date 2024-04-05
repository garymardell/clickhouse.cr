require "../server_packet"
require "../version"

module Clickhoused
  module Packets
    struct Pong < ServerPacket
      def initialize
      end
    end
  end
end