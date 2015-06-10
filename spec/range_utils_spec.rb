$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'range_utils'

RSpec.configure {|c| c.order = 'random' }

describe "RangeUtils" do
  let(:subject) { RangeUtils }
  
  context '.range_includes_item?' do
    it 'properly detects inclusion' do
      range = 5..98
      expect(subject.range_includes_item?(range, 5)).to eq(true)
      expect(subject.range_includes_item?(range, 98)).to eq(true)
      expect(subject.range_includes_item?(range, 97)).to eq(true)
      
      expect(subject.range_includes_item?(range, 1)).to eq(false)
      expect(subject.range_includes_item?(range, 4)).to eq(false)
    end
  end
  
  context '.split_range_into_subranges_of' do
    it 'raises an ArgumentError when the size is < 1' do
      expect {
        subject.split_range_into_subranges_of(15..456, -2)
      }.to raise_error(ArgumentError, 'Chunk size should be > 0, was -2')
      
      expect {
        subject.split_range_into_subranges_of(15..456, 0)
      }.to raise_error(ArgumentError, 'Chunk size should be > 0, was 0')
    end
    
    it 'splits a range into ranges' do
      expect(subject.split_range_into_subranges_of(0..7, 3)).to eq([0..2, 3..5, 6..7])
      expect(subject.split_range_into_subranges_of(0..786, 324)).to eq([0..323, 324..647, 648..786])
      expect(subject.split_range_into_subranges_of(245..786, 324)).to eq([245..568, 569..786])
    end
    
    it 'yields each subrange in succession' do
      expect { |b|
        subject.split_range_into_subranges_of(0..786, 324, &b)
      }.to yield_successive_args(0..323, 324..647, 648..786)
    end
    
    it 'splits a range that spans 1 item' do
      expect(subject.split_range_into_subranges_of(0..0, 1)).to eq([0..0])
      expect(subject.split_range_into_subranges_of(0..0, 15)).to eq([0..0])
    end
    
    it 'handles all division cases without raising exceptions' do
      (1..300).each do | chunk_size |
        subject.split_range_into_subranges_of(0..786, chunk_size)
      end
    end
    
    it 'is usable for HTTP ranges' do
      bytes_total = 3087
      chunk_size = 991
      range = 128..(bytes_total + 128)
      
      ranges = subject.split_range_into_subranges_of(range, chunk_size)
      expect(ranges).to eq([128..1118, 1119..2109, 2110..3100, 3101..3215])
    end
  end
  
  context '.splice' do
    it 'splices adjacent and overlapping ranges, regardless of their ordering in the argument array' do
      expect( subject.splice([500..600, 601..999]) ).to eq([500..999])
      expect( subject.splice([601..999, 500..600]) ).to eq([500..999])
      expect( subject.splice([500..700, 601..999]) ).to eq([500..999])
    end
    
    it 'creates gaps when the ranges cannot be spliced' do
      expect( subject.splice([500..600, 602..999]) ).to eq([500..600, 602..999])
      expect( subject.splice([601..999, 500..600, 10..44]) ).to eq([10..44, 500..999])
    end
  end
  
  context '.ranges_of_offfsets_for_size' do
    it 'raises with a size < 1' do
      expect {
        subject.ranges_of_offfsets_for_size(3, 0)
      }.to raise_error(ArgumentError, 'Chunk size should be > 0, was 0')
      
      expect {
        subject.ranges_of_offfsets_for_size(3, -1)
      }.to raise_error(ArgumentError, 'Chunk size should be > 0, was -1')
    end
    
    it 'creates the ranges that cover the given number of elements' do
      expect(subject.ranges_of_offfsets_for_size(3, 1)).to eq([0..0, 1..1, 2..2])
      expect(subject.ranges_of_offfsets_for_size(3, 2)).to eq([0..1, 2..2])
    end
    
    it 'splits a bigger size' do
      bytes_total = 3087
      chunk_size = 991
      ranges = subject.ranges_of_offfsets_for_size(bytes_total, chunk_size)
      expect(ranges).to eq([0..990, 991..1981, 1982..2972, 2973..3086])
    end
  end
  
  context '.range_for_size_of' do
    it 'raises on size being < 0' do
      expect {
        subject.range_for_size_of(-4)
      }.to raise_error(ArgumentError)
    end
    
    it 'returns a special range for size 0 case' do
      expect(subject.range_for_size_of(0)).to eq(0..-1)
    end
    
    it 'returns the right range for the size' do
      expect(subject.range_for_size_of(456)).to eq(0..455)
    end
  end
  
  context '.http_ranges_for_resource_size' do
    it 'get returned without including the last value' do
      expect(subject.http_ranges_for_size(785, 324)).to eq([0..323, 324..647, 648..784])
    end
  end
end
