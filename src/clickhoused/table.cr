require "./packets/block"

module Clickhoused
  struct Table
    property name : String
    property block : Packets::Block

    def initialize(@name, @block)
    end
  end
end