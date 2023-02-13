module Clickhouse
  abstract class Column
    getter name : String
    getter timezone : Time::Location

    def initialize(@name : String, @timezone : Time::Location)
    end

    abstract def decode(reader : Reader, rows : Uint64)

    def self.for_type(type : String)
      case type
      when "String"
        Columns::StringColumn
      end
    end
  end
end

require "./columns/*"

# type Interface interface {
# 	Name() string
# 	Type() Type
# 	Rows() int
# 	Row(i int, ptr bool) interface{}
# 	ScanRow(dest interface{}, row int) error
# 	Append(v interface{}) (nulls []uint8, err error)
# 	AppendRow(v interface{}) error
# 	Decode(reader *proto.Reader, rows int) error
# 	Encode(buffer *proto.Buffer)
# 	ScanType() reflect.Type
# 	Reset()
# }