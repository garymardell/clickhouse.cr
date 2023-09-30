require "protobuf"

module Clickhoused
  class Writer
    buffer : Protobuf::Buffer

    def initialize
      @io = IO::Memory.new
      @buffer = Protobuf::Buffer.new(@io)
    end

    def write_byte(byte : UInt8)
      @io.write_byte(byte)
    end

    def write_string(str : String)
      write_bytes(str.encode("UTF-8"))
    end

    def reset
      @io.clear
    end

    def size
      @io.size
    end

    def to_slice
      @io.to_slice
    end

    forward_missing_to @buffer
  end
end