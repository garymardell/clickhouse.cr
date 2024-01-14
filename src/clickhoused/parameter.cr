module Clickhoused
  class Parameter
    property key : String
    property value : String

    def initialize(@key, @value)
    end

    def encode(writer : Writer, revision : UInt64)
      writer.write_string(key)
      writer.write_uint64(2_u64)
      writer.write_string("'#{value.gsub("'", "\\'")}'")
    end
  end
end