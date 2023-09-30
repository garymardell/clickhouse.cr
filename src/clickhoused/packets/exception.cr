require "../server_packet"

module Clickhoused
  module Packets
    class Exception < ServerPacket
      property code : UInt32
      property name : String
      property message : String
      property stack_trace : String
      # property children : Array(Exception) # Nested
      property nested : Bool

      def initialize(@code, @name, @message, @stack_trace, @nested)
      end

      def encode(writer : Writer)
      end

      def self.decode(reader : Reader)
        code = reader.read_fixed32.not_nil!
        name = reader.read_string.not_nil!
        message = reader.read_string.not_nil!
        stack_trace = reader.read_string.not_nil!
        nested = reader.read_bool.not_nil!

        new(
          code,
          name,
          message,
          stack_trace,
          nested
        )
      end
    end
  end
end