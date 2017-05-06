require "./spec_helper"

private def to_code(bytes)
  bytes = bytes.map(&.to_u8)
  Slice.new(bytes.to_unsafe, bytes.size, read_only: true)
end

private def run(code)
  Script::Interpreter.new(to_code(code)).run
end

private def peek(code)
  interpreter = Script::Interpreter.new(to_code(code))
  interpreter.run
  interpreter.stack.top
end

private def run(code)
  bytes = code
  bytes = bytes.map(&.to_u8)
  bytes = Slice.new(bytes.to_unsafe, bytes.size, read_only: true)
  Script::Interpreter.new(bytes).run
end

describe Script::Interpreter do
  it "should push an empty array" do
    peek([0x00]).should eq([] of UInt8)
  end

  it "should push variable length data" do
    peek([3, 1, 2, 3]).should eq([1_u8, 2_u8, 3_u8])
  end

  it "should push small integers" do
    peek([88]).should eq([8_u8])
  end

  (82..96).each do |i|
    it "should push #{i} via opcode" do
      peek([i]).should eq([(i - 80).to_u8])
    end
  end

  it "should consider empty array as false" do
    run([0x00]).should eq(false)
  end

  it "should consider zero as false" do
    run([3, 0, 0, 0]).should eq(false)
  end

  it "should consider negative zero as false" do
    run([3, 0, 0, 0x80]).should eq(false)
  end

  it "should consider any other data as true" do
    run([3, 0, 0, 0x81]).should eq(true)
  end

  it "should return error on unknown opcode" do
    result = run([255])
    result.should be_a(Script::Error)
  end

  it "should run a bitcoin pay-to-pubkey-hash transaction check" do
    signature_data_1 = "30440220771ae3ed7f2507f5682d6f63f59fa17187f1c4bdb33aa96373e73d42795d23b702206545376155d36db49560cf9c959d009f8e8ea668d93f47a4c8e9b27dc6b3302301".hexbytes
    signature_data_2 = "048a976a8aa3f805749bf62df59168e49c163abafde1d2b596d685985807a221cbddf5fb72687678c41e35de46db82b49a48a2b9accea3648407c9ce2430724829".hexbytes
    signature_script = [signature_data_1.size] + signature_data_1.to_a + [signature_data_2.size] + signature_data_2.to_a
    pk_data = "0d46f6edc4ac26b62f4f7527e59b5379bde18450".hexbytes.to_a
    pk_script = ([Script::Opcode::OP_DUP, Script::Opcode::OP_HASH160, pk_data.size] + pk_data + [Script::Opcode::OP_EQUALVERIFY, Script::Opcode::OP_CHECKSIG]).map(&.to_u8)
    script = signature_script + pk_script

    run(script).should eq(true)
  end

  it "should fail a bitcoin pay-to-pubkey-hash transaction check due to invalid hash" do
    signature_data_1 = "30440220771ae3ed7f2507f5682d6f63f59fa17187f1c4bdb33aa96373e73d42795d23b702206545376155d36db49560cf9c959d009f8e8ea668d93f47a4c8e9b27dc6b3302301".hexbytes
    signature_data_2 = "048a976a8aa3f805749bf62df59168e49c163abafde1d2b596d685985807a221cbddf5fb72687678c41e35de46db82b49a48a2b9accea3648407c9ce2430724829".hexbytes
    signature_script = [signature_data_1.size] + signature_data_1.to_a + [signature_data_2.size] + signature_data_2.to_a
    pk_data = "0000f6edc4ac26b62f4f7527e59b5379bde18450".hexbytes.to_a
    pk_script = ([Script::Opcode::OP_DUP, Script::Opcode::OP_HASH160, pk_data.size] + pk_data + [Script::Opcode::OP_EQUALVERIFY, Script::Opcode::OP_CHECKSIG]).map(&.to_u8)
    script = signature_script + pk_script

    result = run(script)
    result.should be_a(Script::Error)
    result.as(Script::Error).cause.should eq(Script::Error::Cause::InvalidTransaction)
  end

  pending "should fail a bitcoin pay-to-pubkey-hash transaction check due to invalid signature" do
    signature_data_1 = "00000220771ae3ed7f2507f5682d6f63f59fa17187f1c4bdb33aa96373e73d42795d23b702206545376155d36db49560cf9c959d009f8e8ea668d93f47a4c8e9b27dc6b3302301".hexbytes
    signature_data_2 = "048a976a8aa3f805749bf62df59168e49c163abafde1d2b596d685985807a221cbddf5fb72687678c41e35de46db82b49a48a2b9accea3648407c9ce2430724829".hexbytes
    signature_script = [signature_data_1.size] + signature_data_1.to_a + [signature_data_2.size] + signature_data_2.to_a
    pk_data = "0d46f6edc4ac26b62f4f7527e59b5379bde18450".hexbytes.to_a
    pk_script = ([Script::Opcode::OP_DUP, Script::Opcode::OP_HASH160, pk_data.size] + pk_data + [Script::Opcode::OP_EQUALVERIFY, Script::Opcode::OP_CHECKSIG]).map(&.to_u8)
    script = signature_script + pk_script

    result = run(script)
    result.should be_a(Script::Error)
    result.as(Script::Error).cause.should eq(Script::Error::Cause::InvalidTransaction)
  end
end
