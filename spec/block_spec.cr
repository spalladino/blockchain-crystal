require "./spec_helper"

describe Blockchain::Crystal::Block do
  it "reads a block header" do
    block = block_125552
    block.version.should eq(1)
    block.nonce.should eq(2504433986)
    block.bits.should eq(440711666)
    block.timestamp.should eq(1305998791)
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
    expected_signature_sript = [signature_data_1.size] + signature_data_1.to_a + [signature_data_2.size] + signature_data_2.to_a
    transaction.inputs[0].signature_script.to_a.should eq(expected_signature_sript)
    transaction.inputs[0].sequence.should eq(4294967295)
    transaction.outputs.size.should eq(1)
    transaction.outputs[0].value.should eq(15000000)

    pk_data = "e43f7c61b3ef143b0fe4461c7d26f67377fd2075".hexbytes.to_a
    expected_pk_script = ([Opcode::OP_DUP, Opcode::OP_HASH160, pk_data.size] + pk_data + [Opcode::OP_EQUALVERIFY, Opcode::OP_CHECKSIG]).map(&.to_u8)
    transaction.outputs[0].pk_script.to_a.should eq(expected_pk_script)
  end
end