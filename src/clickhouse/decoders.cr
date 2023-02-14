require "big"
require "json"

module Clickhouse
  module Decoders
    module Decoder
      abstract def decode(value)
      abstract def names : Array(String)

      def decode(value)
        raise "Failed to decode value"
      end

      macro def_names(names)
        NAMES = {{names}}

        def names : Array(String)
          NAMES
        end
      end
    end

    struct Int8Decoder
      include Decoder

      def_names ["Int8", "TINYINT", "INT1"] # "BOOL", "BOOLEAN"

      def decode(value : Int64)
        value.to_i8
      end
    end

    struct Int16Decoder
      include Decoder

      def_names ["Int16", "SMALLINT", "INT2"]

      def decode(value : Int64)
        value.to_i16
      end
    end

    struct Int32Decoder
      include Decoder

      def_names ["Int32", "INT4", "INTEGER"]

      def decode(value : Int64)
        value.to_i32
      end
    end

    struct Int64Decoder
      include Decoder

      def_names ["Int64", "BIGINT"]

      def decode(value : Int64)
        value.to_i64
      end
    end

    struct Int128Decoder
      include Decoder

      def_names ["Int128"]

      def decode(value : String)
        value.to_i128
      end
    end

    struct Int256Decoder
      include Decoder

      def_names ["Int256"]

      def decode(value : String)
        BigInt.new(value)
      end
    end

    struct UInt8Decoder
      include Decoder

      def_names ["UInt8"]

      def decode(value : Int64)
        value.to_u8
      end
    end

    struct UInt16Decoder
      include Decoder

      def_names ["UInt16"]

      def decode(value : Int64)
        value.to_u16
      end
    end

    struct UInt32Decoder
      include Decoder

      def_names ["UInt32"]

      def decode(value : Int64)
        value.to_u32
      end
    end

    struct UInt64Decoder
      include Decoder

      def_names ["UInt64"]

      def decode(value : String)
        value.to_u64
      end
    end

    struct UInt128Decoder
      include Decoder

      def_names ["UInt128"]

      def decode(value : String)
        value.to_u128
      end
    end

    struct UInt256Decoder
      include Decoder

      def_names ["UInt256"]

      def decode(value : String)
        BigInt.new(value)
      end
    end

    struct Float32Decoder
      include Decoder

      def_names ["Float32", "FLOAT"]

      def decode(value : Float64)
        value.to_f32
      end
    end

    struct Float64Decoder
      include Decoder

      def_names ["Float64", "DOUBLE"]

      def decode(value : Float64)
        value.to_f64
      end
    end

    struct BoolDecoder
      include Decoder

      def_names ["Bool"]

      def decode(value : String)
        case value
        when "true"
          true
        when "false"
          false
        else
          raise "Error decoding Bool value"
        end
      end
    end

    struct StringDecoder
      include Decoder

      def_names ["String", "LONGTEXT", "MEDIUMTEXT", "TINYTEXT", "TEXT", "LONGBLOB", "MEDIUMBLOB", "TINYBLOB", "BLOB", "VARCHAR", "CHAR", "FixedString"]

      def decode(value)
        value.to_s
      end
    end

    struct DateTimeDecoder
      include Decoder

      def_names ["DateTime"]

      def decode(value : String)
        Time.parse(value, "%Y-%m-%d %H:%M:%S", Time::Location::UTC)
      end
    end

    struct MapDecoder
      include Decoder

      def_names ["Map(String, String)"]

      def decode(value)
        JSON::Any.new(value).as_h.transform_values do |value|
          value.to_s
        end
      end
    end

    @@decoders = Hash(String, Decoder).new

    def self.for_name(name : String) : Decoder
      @@decoders[name]
    end

    def self.register_decoder(decoder : Decoder)
      decoder.names.each do |name|
        @@decoders[name] = decoder
      end
    end

    register_decoder Int8Decoder.new
    register_decoder Int16Decoder.new
    register_decoder Int32Decoder.new
    register_decoder Int64Decoder.new
    register_decoder Int128Decoder.new
    register_decoder Int256Decoder.new
    register_decoder UInt8Decoder.new
    register_decoder UInt16Decoder.new
    register_decoder UInt32Decoder.new
    register_decoder UInt64Decoder.new
    register_decoder UInt128Decoder.new
    register_decoder UInt256Decoder.new
    register_decoder Float32Decoder.new
    register_decoder Float64Decoder.new
    register_decoder BoolDecoder.new
    register_decoder StringDecoder.new
    register_decoder DateTimeDecoder.new
    register_decoder MapDecoder.new
  end
end