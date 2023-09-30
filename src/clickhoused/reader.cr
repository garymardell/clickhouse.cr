require "big"
require "protobuf"

module Clickhoused
  class Reader
    buffer : Protobuf::Buffer

    def initialize(@io : IO)
      @buffer = Protobuf::Buffer.new(@io)
    end

    def read_byte : UInt8 | Nil
      @io.read_byte
    end

    def read_fixed8
      @io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    end

    def read_sfixed8
      @io.read_bytes(Int8, IO::ByteFormat::LittleEndian)
    end

    def read_fixed16
      @io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
    end

    def read_sfixed16
      @io.read_bytes(Int16, IO::ByteFormat::LittleEndian)
    end

    def read_fixed128
      @io.read_bytes(UInt128, IO::ByteFormat::LittleEndian)
    end

    def read_sfixed128
      @io.read_bytes(Int128, IO::ByteFormat::LittleEndian)
    end

    def read_fixed256
      @io.read_bytes(UInt256, IO::ByteFormat::LittleEndian)
    end

    def read_sfixed256
      @io.read_bytes(Int256, IO::ByteFormat::LittleEndian)
    end

    def read_bigint
      @io.read_bytes(BigInt, IO::ByteFormat::LittleEndian)
    end

    forward_missing_to @buffer
  end
end