module Clickhouse
  module Protocol
    struct Exception
      include Message

      property code : Int32
      property name : String
      property message : String
      property stack_trace : String
      property children : Array(Exception) # Nested
      property nested : Bool

      def initialize(@code, @name, @message, @stack_trace, @children, @nested)
      end

      def encode(encoder : Encoder)
      end
    end
  end
end