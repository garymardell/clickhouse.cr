module Clickhouse
  abstract class Column
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