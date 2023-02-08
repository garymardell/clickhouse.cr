module Clickhouse
  class Reader
    buffer : Protobuf::Buffer

    def initialize(@io : IO)
      @buffer = Protobuf::Buffer.new(@io)
    end

    def read_byte : UInt8 | Nil
      @io.read_byte
    end

    forward_missing_to @buffer
  end
end