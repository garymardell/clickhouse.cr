require "./table"

module Clickhoused
  struct QueryOptions
    property query_id : String
    property external : Array(Table)
    property user_location : Time::Location?

    def initialize(
      @query_id : String = "",
      @external = [] of Table,
      @user_location : Time::Location? = nil
    )
    end
  end
end