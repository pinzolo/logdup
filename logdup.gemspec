# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logdup/version'

Gem::Specification.new do |spec|
  spec.name          = "logdup"
  spec.version       = Logdup::VERSION
  spec.authors       = ["pinzolo"]
  spec.email         = ["pinzolo@gmail.com"]
  spec.description   = %q{Logdup duplicates logs partially.}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/pinzolo/logdup"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "coveralls"
end
