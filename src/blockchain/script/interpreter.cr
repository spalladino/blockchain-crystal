class Script::Interpreter
  getter stack
  getter! transaction

  TRUE  = [1_u8]
  FALSE = Array(UInt8).new(0)

  def initialize(@code : Bytes, @transaction : Blockchain::Transaction? = nil)
    @stack = Array(Array(UInt8)).new
    @ip = 0
    @last_code_separator = 0
  end

  def run : Result
    while @ip < @code.size
      op = Opcode.new(@code[@ip])
      case op
      when Opcode::OP_FALSE
        # Push false to the stack
        stack.push(FALSE)
        @ip += 1
      when (Opcode::OP_2..Opcode::OP_16)
        # Push 2 to 16 bytes to the stack
        stack.push(as_array(op.value - Opcode::OP_2.value + 2))
        @ip += 1
      when (Opcode::NA_DATA_MIN..Opcode::NA_DATA_MAX)
        # Push the next opcode bytes to the stack
        size = op.value
        data = as_array(@code[@ip + 1, size])
        stack.push data
        @ip += (size + 1)
      when Opcode::OP_DUP
        # Duplicate stack top
        stack.push(stack.top.clone)
        @ip += 1
      when Opcode::OP_HASH160
        # Hash with SHA256 then RIPEMD160
        stack[-1] = as_array(Blockchain::Digest.hash160(stack[-1].as_slice))
        @ip += 1
      when Opcode::OP_CHECKSIG
        pub_key = stack.pop
        signature = stack.pop
        result = check_sig(pub_key, signature)
        stack.push as_array(result ? 1_u8 : 0_u8)
        @ip += 1
      when Opcode::OP_EQUALVERIFY
        first, second = stack.pop, stack.pop
        if first != second
          return Error.new(Error::Cause::InvalidTransaction)
        end
        @ip += 1
      when Opcode::OP_CODESEPARATOR
        @last_code_separator = @ip
        @ip += 1
      else
        return Error.new(Error::Cause::UnknownOpcode, as_array(op.value))
      end
    end

    to_bool(@stack.top)
  end

  def check_sig(pub_key, signature)
    true
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
