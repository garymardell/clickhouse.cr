module Clickhouse
  module Protocol
    struct Query
      include Message

      property id : String
      property body : String
      property quota_key : String
      # property settings : Settings
      property compression : Bool
      property initial_user : String
      property initial_address : String

      def initialize(@id, @body, @quota_key, @compression, @initial_user, @initial_address)
      end

      def encode(encoder : Encoder)
      end
    end
  end
end