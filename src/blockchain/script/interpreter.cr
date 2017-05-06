class Script::Interpreter
  getter stack

  def initialize(@code : Bytes)
    @stack = Array(Array(UInt8)).new
    @ip = 0
  end

  def run : Result
    while @ip < @code.size
      op = Opcode.new(@code[@ip])
      case op
      when Opcode::OP_FALSE
        stack.push(Array(UInt8).new(0))
        @ip += 1
      when (Opcode::OP_2..Opcode::OP_16)
        stack.push(as_array(op.value - Opcode::OP_2.value + 2))
        @ip += 1
      when (Opcode::NA_DATA_MIN..Opcode::NA_DATA_MAX)
        size = op.value
        data = as_array(@code[@ip + 1, size])
        stack.push data
        @ip += (size + 1)
      else
        return Error.new(Error::Cause::UnknownOpcode, as_array(op.value))
      end
    end

    to_bool(@stack.top)
  end

  private def as_array(number : UInt8)
    [number]
  end

  private def as_array(slice : Bytes)
    size = slice.size
    Array(UInt8).build(size) do |buffer|
      slice.copy_to(buffer, size)
      size
    end
  end

  private def to_bool(bytes)
    bytes.each_with_index do |byte, index|
      if byte != 0_u8
        return index < bytes.size - 1 || byte != 0x80_u8
      end
    end
    return false
  end
end
