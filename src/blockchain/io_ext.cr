module IO
  def read_var_int
    first = read_byte.not_nil!
    if first < 0xFD
      first
    elsif first == 0xFD
      read_bytes(UInt16, IO::ByteFormat::LittleEndian)
    elsif first == 0xFE
      read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    elsif first == 0xFF
      read_bytes(UInt64, IO::ByteFormat::LittleEndian)
    else
      raise "Invalid var int"
    end.to_u64
  end

  def read_var_bytes
    size = read_var_int
    slice = Bytes.new(size)
    read(slice)
    slice
  end

  def read_hash
    slice = Bytes.new(32)
    read(slice)
    slice
  end
end
