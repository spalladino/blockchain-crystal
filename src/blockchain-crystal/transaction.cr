class Blockchain::Crystal::Transaction
  class Outpoint
    getter hash : Bytes
    getter index : UInt32

    def initialize(io : IO)
      @hash = io.read_hash
      @index = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    end
  end

  class Input
    getter previous_outpoint : Outpoint
    getter signature_script : Bytes
    getter sequence : UInt32

    def initialize(io : IO)
      @previous_outpoint = Outpoint.new(io)
      @signature_script = io.read_var_bytes
      @sequence = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    end
  end

  class Output
    getter value : Int64
    getter pk_script : Bytes

    def initialize(io : IO)
      @value = io.read_bytes(Int64, IO::ByteFormat::LittleEndian)
      @pk_script = io.read_var_bytes
    end
  end

  getter version : Int32
  getter input_count : UInt64
  getter inputs : Array(Input)
  getter output_count : UInt64
  getter outputs : Array(Output)
  getter lock_time : UInt32
  getter hash : Bytes

  # See https://en.bitcoin.it/wiki/Protocol_documentation#tx
  def initialize(base_io : IO)
    io = OpenSSL::DigestIO.new(base_io, "SHA256")
    @version = io.read_bytes(Int32, IO::ByteFormat::LittleEndian)

    @input_count = io.read_var_int
    @inputs = Array(Input).new(input_count)
    @input_count.times { @inputs << Input.new(io) }

    @output_count = io.read_var_int
    @outputs = Array(Output).new(output_count)
    @output_count.times { @outputs << Output.new(io) }

    @lock_time = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    @hash = OpenSSL::Digest.new("SHA256").update(io.digest).digest.reverse!
  end
end
