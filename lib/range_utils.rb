module RangeUtils
  VERSION = '1.3.1'
  
  NegativeRangeSpan = Class.new(ArgumentError)
  
  # Tells whether the +item+ is included in the +range+, without enumerating
  # through the +range+ (performing a quick bounds check).
  # The first value of the range and the +item+ have to support +<=>+
  def range_includes_item?(range, item)
    range.begin <= item && item <= range.end
  end
  
  # Splits the given Range into subranges of +size+.
  #
  #   split_range_into_subranges_of(0..7, 3) #=> [0..2, 3..5, 5..7]
  # 
  # Range members must support +<=>+ and arithmetic with integers.
  # +size+ has to be > 0.
  def split_range_into_subranges_of(range, size)
    raise ArgumentError, "Chunk size should be > 0, was #{size}" unless size > 0
    
    num_values = range.end - range.begin + 1
    ranges = []
    at = range.begin
    loop do
      if at > range.end
        return ranges
      else
        end_of_chunk = (at + size - 1)
        current = at..(end_of_chunk > range.end ? range.end : end_of_chunk)
        at = (at + size)
        ranges << current
        yield(current) if block_given?
      end
    end
  end
  
  # Returns ranges for the given size. The returned ranges start at zero.
  # Can be used to split a Content-Length of an HTTP resource into
  # ranges usable in Range: header for instance.
  #
  # Since the initial offset is 0 the resulting ranges will always end at
  # +size - 1+
  #
  #   ranges_of_offfsets_for_size(3, 1) #=> [0..0, 1..1, 2..2]
  #   ranges_of_offfsets_for_size(3, 2) #=> [0..1, 2..2]
  # 
  # Range members must support +<=>+ and arithmetic with integers.
  # +size+ has to be > 0.
  def ranges_of_offfsets_for_size(number_of_items, chunk_size)
    raise ArgumentError, "Chunk size should be > 0, was #{chunk_size}" unless chunk_size > 0
    split_range_into_subranges_of(range_for_size_of(number_of_items), chunk_size)
  end
  
  # Creates a Range that can be used to grab N first elements from, say,
  # an Array or a String.
  #   range_for_size(14) #=> 0..13
  #   "abcd"[range_for_size(2)] #=> "ab"
  #
  # +number_of_items+ should be >= 0. For the +number_of_items+
  # a special Range of 0..-1 will be returned (note that this Range cannot fetch anything).
  def range_for_size_of(number_of_items)
    raise ArgumentError, "Number of items should be at least 0, was #{number_of_items}"  if number_of_items < 0
    (0..(number_of_items - 1))
  end
  
  # Combine ranges with adjacent or overlapping values (create a union range).
  #   splice([0..0, 0..4, 5..14, 16..20]) #=> [0..14, 16..20]
  # Range members must support +<=>+ and arithmetic with integers.
  def splice(ranges)
    ranges.sort_by(&:begin).inject([]) do | spliced, r |
      if spliced.empty?
        spliced + [r]
      else
        last = spliced.pop
        if last.end >= (r.begin - 1)
          ends = [last.end, last.begin, r.begin, r.end].sort
          new_end, new_begin = ends.shift, ends.pop
          spliced + [(new_end..new_begin)]
        else
          spliced + [last, r]
        end
      end
    end
  end
  
  # Returns the number of members of the given Range.
  #   size_from_range(0..0) #=> 1
  #   size_from_range(12..123) #=> 112
  # Range members must support arithmetic with integers.
  def size_from_range(range)
    size = range.end - range.begin + 1
    raise NegativeRangeSpan, "The resulting size for range #{range} is negative" if size < 0
    size
  end
  
  # Take N items from the range, and return two Ranges
  # the first being the range containing N items requested,
  # and the other containing the remainder
  #   take(4..514, 3) #=> [4..6, 7..514]
  # If the range is too small for the number of items requested, the range itself and +nil+ will
  # be returned instead:
  #
  #   take(4..514, 1024) #=> [4..514, nil]
  #
  # Range members and n_items must support arithmetic with integers
  def take(from_range, n_items)
    end_at = from_range.begin + (n_items - 1)
    return [from_range, nil] if end_at >= from_range.end
    [from_range.begin..end_at, end_at.succ..from_range.end]
  end
  
  alias_method :http_ranges_for_size, :ranges_of_offfsets_for_size
  extend self
end
