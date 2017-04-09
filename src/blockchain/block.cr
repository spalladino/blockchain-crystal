require "./transaction"

class Blockchain::Block
  # See https://en.bitcoin.it/wiki/Protocol_documentation#Block_Headers
  class Header
    getter version : Int32
    getter hash_prev_block : Bytes
    getter hash_merkle_root : Bytes
    getter timestamp : UInt32
    getter bits : UInt32
    getter nonce : UInt32
    getter hash : Bytes

    def initialize(base_io : IO)
      io = OpenSSL::DigestIO.new(base_io, "SHA256")
      @version = io.read_bytes(Int32, IO::ByteFormat::LittleEndian)
      @hash_prev_block = io.read_hash
      @hash_merkle_root = io.read_hash
      @timestamp = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      @bits = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      @nonce = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      @hash = OpenSSL::Digest.new("SHA256").update(io.digest).digest.reverse!
    end
  end

  getter transaction_count : UInt64
  getter transactions : Array(Transaction)
  getter header : Header

  delegate version, hash_prev_block, hash_merkle_root, timestamp, bits, nonce, hash, to: @header

  def initialize(io : IO)
    @header = Header.new(io)
    @transaction_count = io.read_var_int
    @transactions = Array(Transaction).new(transaction_count)
    @transaction_count.times { @transactions << Transaction.new(io) }
  end
end
