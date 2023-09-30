require "./packets/exception"

module Clickhoused
  class Error < Exception
  end

  class ConnectionError < Error
  end

  class UnsupportedRevisionError < Error
  end

  class PacketNotImplementedError < Error
  end
end