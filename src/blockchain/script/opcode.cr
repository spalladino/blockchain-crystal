# See https://en.bitcoin.it/wiki/Script
enum Script::Opcode : UInt8
  NA_DATA_MIN       =   1
  NA_DATA_MAX       =  75
  OP_FALSE          =   0
  OP_PUSHDATA1      =  76
  OP_PUSHDATA2      =  77
  OP_PUSHDATA4      =  78
  OP_1NEGATE        =  79
  OP_TRUE           =  81
  OP_2              =  82
  OP_16             =  96
  OP_DUP            = 118
  OP_EQUALVERIFY    = 136
  OP_HASH160        = 169
  OP_CODESEPARATOR  = 171
  OP_CHECKSIG       = 172
  OP_CHECKSIGVERIFY = 173
end
