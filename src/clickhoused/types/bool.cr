require "../type"

module Clickhoused
  module Types
    class Bool < Clickhoused::Type(Bool)
      def self.name
        "Bool"
      end

      def self.encode(writer : Writer)
      end

      def self.decode(reader : Reader)
        new(reader.read_bool)
      end
    end
  end
end