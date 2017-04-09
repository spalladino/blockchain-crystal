module Blockchain::Digest
  def self.dhash(*bytes)
    algorithm = OpenSSL::Digest.new("SHA256")
    first = bytes.reduce(algorithm) { |a, b| a.update(b) }
    OpenSSL::Digest.new("SHA256").update(first.digest).digest
  end
end
