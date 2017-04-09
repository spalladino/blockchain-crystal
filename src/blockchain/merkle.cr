require "./digest"

module Blockchain::Merkle
  def self.calculate_root(hashes : Array(Bytes))
    raise "Cannot calculate root of empty set" if hashes.empty?
    while hashes.size > 1
      next_row = Array(Bytes).new(hashes.size)
      (hashes.size / 2).times do |i|
        next_row << Digest.dhash(hashes[i * 2], hashes[i * 2 + 1])
      end
      if hashes.size.odd?
        next_row << Digest.dhash(hashes[-1], hashes[-1])
      end
      hashes = next_row
    end
    hashes[0]
  end
end
