module RangeUtils
  require_relative 'range_utils/version'

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
  def split_range_into_subranges_of(range, chunk_size)
    raise ArgumentError, "Chunk size should be > 0, was #{chunk_size}" if chunk_size < 1
    raise ArgumentError, "The given range to split must be inclusive" if range.exclude_end?
    raise ArgumentError, "The given range to split must be finite" unless range.size.finite?

    # To be compatible with the previous version,
    # the default should return an Array - not an Enumerator. If one wishes an Enumerator
    # enum_for can always be used explicitly.
    unless block_given?
      return enum_for(:split_range_into_subranges_of, range, chunk_size).to_a
    end

    whole_subranges, remainder = range.size.divmod(chunk_size)
    whole_subranges.times do |n|
      subrange_start = range.begin + (n * chunk_size)
      subrange_end = subrange_start + chunk_size - 1
      yield(subrange_start..subrange_end)
    end
    if remainder > 0
      subrange_start = range.begin + (whole_subranges * chunk_size)
      subrange_end = subrange_start + remainder - 1
      yield(subrange_start..subrange_end)
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
    ranges.sort_by(&:begin).inject([]) do |spliced, r|
      if spliced.empty?
        spliced + [r]
      else
        last = spliced.pop
        if last.end >= (r.begin - 1)
          ends = [last.end, last.begin, r.begin, r.end].sort
          new_end = ends.shift
          new_begin = ends.pop
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

  # Returns the intersection of two given Ranges or `nil` if they do not intersect.
  # Adjacent ranges do not get merged.
  #
  #   intersection_of(0..456, 26..12889) #=> 26..456
  #   intersection_of(0..456, 7811..12889) #=> nil
  #   intersection_of(0..0, 1..1) #=> nil
  #
  # Range members and n_items must support arithmetic with integers
  def intersection_of(range_a, range_b)
    range_a, range_b = [range_a, range_b].sort_by(&:begin)
    return if range_a.end < range_b.begin
    heads_and_tails = [range_a.begin, range_b.begin, range_a.end, range_b.end].sort
    middle = heads_and_tails[1..-2]
    middle[0]..middle[1]
  end

  alias_method :http_ranges_for_size, :ranges_of_offfsets_for_size
  extend self
end
