class Script::Error
  enum Cause
    UnknownOpcode
  end

  getter cause
  getter data

  def initialize(@cause : Cause, @data : Array(UInt8)?)
  end
end
