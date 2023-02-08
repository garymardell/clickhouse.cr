module Clickhouse
  module Protocol
    ClientHello  = 0_u64
    ClientQuery  = 1_u64
    ClientData   = 2_u64
    ClientCancel = 3_u8
    ClientPing   = 4_u8

    ClientQueryNone      = 0_u8
	  ClientQueryInitial   = 1_u8

    CompressEnable  = 1_u64
	  CompressDisable = 0_u64

    StateComplete = 2_u64

    ServerHello               = 0_u8
    ServerData                = 1_u8
    ServerException           = 2_u8
    ServerProgress            = 3_u8
    ServerPong                = 4_u8
    ServerEndOfStream         = 5_u8
    ServerProfileInfo         = 6_u8
    ServerTotals              = 7_u8
    ServerExtremes            = 8_u8
    ServerTablesStatus        = 9_u8
    ServerLog                 = 10_u8
    ServerTableColumns        = 11_u8
    ServerPartUUIDs           = 12_u8
    ServerReadTaskRequest     = 13_u8
    ServerProfileEvents       = 14_u8
    ServerTreeReadTaskRequest = 15_u8
  end
end