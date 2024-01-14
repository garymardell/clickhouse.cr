require "./table"
require "./parameter"

module Clickhoused
  struct QueryOptions
    property query_id : String
    property external : Array(Table)
    property user_location : Time::Location?
    property parameters : Array(Parameter)

    def initialize(
      @query_id : String = "",
      @external = [] of Table,
      @user_location : Time::Location? = nil,
      @parameters : Array(Parameter) = [] of Parameter
    )
    end
  end
end