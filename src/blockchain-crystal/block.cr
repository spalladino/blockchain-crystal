require "./transaction"

class Blockchain::Crystal::Block
  getter version : Int32
  getter hashPrevBlock : Bytes
  getter hashMerkleRoot : Bytes
  getter timestamp : UInt32
  getter bits : UInt32
  getter nonce : UInt32
  getter transaction_count : UInt64
  getter transactions : Array(Transaction)

  # See https://en.bitcoin.it/wiki/Protocol_documentation#Block_Headers
  def initialize(io : IO)
    @version = io.read_bytes(Int32, IO::ByteFormat::LittleEndian)
    @hashPrevBlock = Bytes.new(32)
    io.read(@hashPrevBlock)
    @hashMerkleRoot = Bytes.new(32)
    io.read(@hashMerkleRoot)
    @timestamp = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    @bits = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    @nonce = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    @transaction_count = io.read_var_int
    @transactions = Array(Transaction).new(transaction_count)
    @transaction_count.times { @transactions << Transaction.new(io) }
  end
end
