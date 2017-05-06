require "./spec_helper"

describe Blockchain::Block do
  it "reads a block header" do
    block = block_125552
    block.version.should eq(1)
    block.nonce.should eq(2504433986)
    block.bits.should eq(440711666)
    block.timestamp.should eq(1305998791)
    block.hash_prev_block.should eq("00000000000008a3a41b85b8b29ad444def299fee21793cd8b9e567eab02cd81".hexbytes.reverse!)
    block.hash_merkle_root.should eq("2b12fcf1b09288fcaff797d71e950e71ae42b91e8bdb2304758dfcffc2b620e3".hexbytes.reverse!)
  end

  it "reads number of transactions" do
    block = block_125552
    block.transaction_count.should eq(4)
  end

  it "reads all transactions" do
    block = block_125552
    block.transactions.size.should eq(4)
  end

  it "reads all transaction data" do
    block = block_125552
    transaction = block.transactions[-1]
    transaction.version.should eq(1)
    transaction.input_count.should eq(2)
    transaction.output_count.should eq(1)

    transaction.inputs.size.should eq(2)
    transaction.inputs[0].previous_outpoint.hash.should eq("7ae1847583b78ea9534b2da74134aa89a4d013a6b31631e71a27b9026435a8c8".hexbytes.reverse!)
    transaction.inputs[0].previous_outpoint.index.should eq(1)

    signature_data_1 = "30440220771ae3ed7f2507f5682d6f63f59fa17187f1c4bdb33aa96373e73d42795d23b702206545376155d36db49560cf9c959d009f8e8ea668d93f47a4c8e9b27dc6b3302301".hexbytes
    signature_data_2 = "048a976a8aa3f805749bf62df59168e49c163abafde1d2b596d685985807a221cbddf5fb72687678c41e35de46db82b49a48a2b9accea3648407c9ce2430724829".hexbytes
    expected_signature_script = [signature_data_1.size] + signature_data_1.to_a + [signature_data_2.size] + signature_data_2.to_a
    transaction.inputs[0].signature_script.to_a.should eq(expected_signature_script)
    transaction.inputs[0].sequence.should eq(4294967295)
    transaction.outputs.size.should eq(1)
    transaction.outputs[0].value.should eq(15000000)

    pk_data = "e43f7c61b3ef143b0fe4461c7d26f67377fd2075".hexbytes.to_a
    expected_pk_script = ([Script::Opcode::OP_DUP, Script::Opcode::OP_HASH160, pk_data.size] + pk_data + [Script::Opcode::OP_EQUALVERIFY, Script::Opcode::OP_CHECKSIG]).map(&.to_u8)
    transaction.outputs[0].pk_script.to_a.should eq(expected_pk_script)
  end

  it "computes hash of a transaction" do
    block = block_125552
    transaction = block.transactions[-1]
    expected = "b519286a1040da6ad83c783eb2872659eaf57b1bec088e614776ffe7dc8f6d01".hexbytes.reverse!
    transaction.hash.should eq(expected)
  end

  it "computes hash of a block" do
    block = block_125552
    expected = "00000000000000001e8d6829a8a21adc5d38d0a473b144b6765798e61f98bd1d".hexbytes.reverse!
    block.hash.should eq(expected)
  end

  it "validates merkle root" do
    block = block_125552
    block.validate_merkle_root!
  end

  it "fails merkle root validation" do
    block = block_125552
    block.hash_merkle_root = "7ae1847583b78ea9534b2da74134aa89a4d013a6b31631e71a27b9026435a8c8".hexbytes
    expect_raises { block.validate_merkle_root! }
  end
end
