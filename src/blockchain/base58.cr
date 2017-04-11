require "big_int"
require "./digest"

module Blockchain::Base58
  CODE = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

  TABLE = Hash(Char, Int32).new
  {% for char, index in CODE.chars %}
    TABLE[{{ char }}] = {{ index }}
  {% end %}

  # See https://en.bitcoin.it/wiki/Base58Check_encoding
  def self.encode_check(version : UInt8, payload : Bytes)
    # Double sha256 of version concatenated with payload
    hash = Digest.dhash(Bytes.new(1, version), payload)[0, 4]

    # Concatenate version, payload and hash prefix
    data = Bytes.new(1 + payload.size + 4)
    data[0] = version
    (data + 1).copy_from(payload)
    (data + 1 + payload.size).copy_from(hash)

    # Treat it as a bignumber
    number = BigInt.new(data.hexstring, base: 16)

    String.build do |str|
      # Encode as base58
      while number > 0
        str << CODE[number % 58]
        number = number / 58
      end

      # Add a leading 1 for each zero in data
      i = 0
      while data[i] == 0_u8
        str << "1"
        i += 1
      end
    end.reverse
  end

  def self.decode(string)
    # Count number of leading ones in string
    leading_ones = 0
    while string[leading_ones] == '1'
      leading_ones += 1
    end

    # Iterate the string from the least significant char
    # and stop when we have reached the leading zeroes
    number = BigInt.new
    power = BigInt.new(1)
    string.reverse.each_char.with_index do |char, index|
      break if index + leading_ones == string.size
      number += TABLE[char] * power
      power *= 58
    end

    # Number as slice, adding leading zeros
    String.build do |str|
      leading_ones.times { str << "00" }
      hex = number.to_s(16)
      str << "0" if hex.size.odd?
      str << hex
    end.hexbytes
  end
end
