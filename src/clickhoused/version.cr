module Clickhoused
  class Version
    property major : UInt64
    property minor : UInt64
    property patch : UInt64

    def initialize(@major, @minor, @patch)
    end
  end
end