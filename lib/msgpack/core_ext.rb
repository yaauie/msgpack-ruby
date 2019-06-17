module MessagePack
  module CoreExt
    def to_msgpack(packer_or_io = nil)
      if packer_or_io
        if packer_or_io.is_a?(MessagePack::Packer)
          to_msgpack_with_packer packer_or_io
        else
          MessagePack.pack(self, packer_or_io)
        end
      else
        MessagePack.pack(self)
      end
    end
  end

  # 3-arg Time.at is available Ruby >= 2.5
  TIME_AT_3_AVAILABLE = begin
    Time.at(0, 0, :nanosecond)
    true
  rescue ArgumentError
    false
  end
end

class NilClass
  include MessagePack::CoreExt

  private
  def to_msgpack_with_packer(packer)
    packer.write_nil
    packer
  end
end

class TrueClass
  include MessagePack::CoreExt

  private
  def to_msgpack_with_packer(packer)
    packer.write_true
    packer
  end
end

class FalseClass
  include MessagePack::CoreExt

  private
  def to_msgpack_with_packer(packer)
    packer.write_false
    packer
  end
end

class Float
  include MessagePack::CoreExt

  private
  def to_msgpack_with_packer(packer)
    packer.write_float self
    packer
  end
end

class String
  include MessagePack::CoreExt

  private
  def to_msgpack_with_packer(packer)
    packer.write_string self
    packer
  end
end

class Array
  include MessagePack::CoreExt

  private
  def to_msgpack_with_packer(packer)
    packer.write_array self
    packer
  end
end

class Hash
  include MessagePack::CoreExt

  private
  def to_msgpack_with_packer(packer)
    packer.write_hash self
    packer
  end
end

class Symbol
  include MessagePack::CoreExt

  private
  def to_msgpack_with_packer(packer)
    packer.write_symbol self
    packer
  end
end

if 1.class.name == "Integer"
  class Integer
    include MessagePack::CoreExt

    private
    def to_msgpack_with_packer(packer)
      packer.write_int self
      packer
    end
  end
else
  class Fixnum
    include MessagePack::CoreExt

    private
    def to_msgpack_with_packer(packer)
      packer.write_int self
      packer
    end
  end

  class Bignum
    include MessagePack::CoreExt

    private
    def to_msgpack_with_packer(packer)
      packer.write_int self
      packer
    end
  end
end

class Time
  include MessagePack::CoreExt

  def self.from_msgpack_ext(payload)
    tv = MessagePack::Timestamp.from_msgpack_ext(payload)

    if MessagePack::TIME_AT_3_AVAILABLE
      at(tv.sec, tv.nsec, :nanosecond)
    else
      at(tv.sec, tv.nsec / 1000.0)
    end
  end

  def to_msgpack_ext
    MessagePack::Timestamp.to_msgpack_ext(tv_sec, tv_nsec)
  end
end

module MessagePack
  class ExtensionValue
    include CoreExt

    private
    def to_msgpack_with_packer(packer)
      packer.write_extension self
      packer
    end
  end
end
