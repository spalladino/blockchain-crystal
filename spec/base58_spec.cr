require "./spec_helper"

describe Blockchain::Base58 do
  it "should generate base58 encoding with version and hash for a bitcoin address" do
    input = "010966776006953D5567439E5E39F86A0D273BEE".hexbytes
    Blockchain::Base58.encode_check(0_u8, input).should eq("16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM")
  end

  it "should decode a base58 string" do
    value = "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM"
    expected = "00010966776006953D5567439E5E39F86A0D273BEED61967F6".hexbytes
    Blockchain::Base58.decode(value).should eq(expected)
  end
end
