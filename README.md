# range_utils

[![Build Status](https://travis-ci.org/julik/range_utils.svg?branch=master)](https://travis-ci.org/julik/range_utils)

There is more to a Range than meets the eye. Or more to the eye than meets the Range. Or whatever.

`RangeUtils` is a non-intrusive module for doing useful things to Range objects.
It is mainly useful for working with batches of IDs and HTTP content ranges.

## Usage

    # Combine consecutive Range objects:
    RangeUtils.splice([0..0, 0..4, 5..14, 16..20]) #=> [0..14, 16..20]
    
    # Get the range for a given size of the collection:
    RangeUtils.range_for_size_of(14) #=> 0..13
    
    # or get the size from a Range:
    RangeUtils.size_from_range(0..0) #=> 1
    RangeUtils.size_from_range(12..123) #=> 112
    
    # Get the Ranges of maximum size for a given number of elements:
    RangeUtils.ranges_of_offfsets_for_size(3, 1) #=> [0..0, 1..1, 2..2]
    
    # Split a large Range into smaller ranges of given maximum size:
    RangeUtils.split_range_into_subranges_of(0..7, 3) #=> [0..2, 3..5, 5..7]
    
    # Prepare a number of HTTP Range headers (each request will be 1 byte):
    RangeUtils.http_ranges_for_size(3, 1) #=> [0..0, 1..1, 2..2]

## Contributing to range_utils
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 Julik Tarkhanov. See LICENSE.txt for
further details.

