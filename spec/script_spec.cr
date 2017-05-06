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
end
