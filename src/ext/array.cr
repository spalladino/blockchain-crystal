class Array(T)
  def top
    last
  end

  def as_slice
    Slice.new(self.to_unsafe, self.size, read_only: false)
  end
end
