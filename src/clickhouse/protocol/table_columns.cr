module Clickhouse
  module Protocol
    struct TableColumn
      include Message

      property first : String
      property second : String

      def initialize(@first, @second)
      end

      def encode(buffer : Buffer)
      end
    end
  end
end