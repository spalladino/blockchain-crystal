class Script::Error
  enum Cause
    UnknownOpcode,
    InvalidTransaction
  end

  getter cause
  getter data

  def initialize(@cause : Cause, @data : Array(UInt8)? = nil)
  end
end
