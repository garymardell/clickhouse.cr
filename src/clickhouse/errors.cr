module Clickhouse
  class Error < ::Exception
  end

  class ServerError < ::Exception
    property server_exception : Protocol::Exception

    def initialize(@server_exception : Protocol::Exception)
      super(@server_exception.message)
    end
  end
end