require "./spec_helper"

describe Blockchain::Merkle do
  it "calculates merkle root for 4 items" do
    hashes = [
      "51d37bdd871c9e1f4d5541be67a6ab625e32028744d7d4609d0c37747b40cd2d",
      "60c25dda8d41f8d3d7d5c6249e2ea1b05a25bf7ae2ad6d904b512b31f997e1a1",
      "01f314cdd8566d3e5dbdd97de2d9fbfbfd6873e916a00d48758282cbb81a45b9",
      "b519286a1040da6ad83c783eb2872659eaf57b1bec088e614776ffe7dc8f6d01",
    ].map(&.hexbytes.reverse!)
    expected = "2b12fcf1b09288fcaff797d71e950e71ae42b91e8bdb2304758dfcffc2b620e3".hexbytes.reverse!
    Blockchain::Merkle.calculate_root(hashes).should eq(expected)
  end
end
