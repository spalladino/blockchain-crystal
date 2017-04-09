require "spec"
require "../src/blockchain"

# See https://webbtc.com/block/00000000000000001e8d6829a8a21adc5d38d0a473b144b6765798e61f98bd1d
def block_125552
  bytes = File.read("spec/data/125552.hex").strip.hexbytes
  io = IO::Memory.new(bytes, false)
  Blockchain::Block.new(io)
end
