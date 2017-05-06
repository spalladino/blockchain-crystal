module Blockchain::Digest
  def self.dhash(*bytes)
    algorithm = OpenSSL::Digest.new("SHA256")
    first = bytes.reduce(algorithm) { |a, b| a.update(b) }
    OpenSSL::Digest.new("SHA256").update(first.digest).digest
  end

  def self.ripemd160(*bytes)
    algorithm = OpenSSL::Digest.new("RIPEMD160")
    bytes.reduce(algorithm) { |a, b| a.update(b) }.digest
  end

  def self.hash160(*bytes)
    algorithm = OpenSSL::Digest.new("SHA256")
    first = bytes.reduce(algorithm) { |a, b| a.update(b) }
    OpenSSL::Digest.new("RIPEMD160").update(first.digest).digest
  end
end
