lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'range_utils/version'

Gem::Specification.new do |spec|
  spec.name           = 'range_utils'
  spec.version        = RangeUtils::VERSION
  spec.authors        = ['Julik Tarkhanov']
  spec.email          = ['me@julik.nl']

  spec.description = %Q{There is a whole range of things you can do with a Range}
  spec.summary = %Q{Range splice, split and other niceties}
  spec.homepage       = 'http://github.com/wetransfer/range_utils'

  # Prevent pushing this gem to RubyGems.org.
  # To allow pushes either set the 'allowed_push_host'
  # To allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0")
  spec.bindir         = 'exe'
  spec.executables    = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths  = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake', '~> 12.2'
  spec.add_development_dependency 'rspec', '~> 3'
end
