# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_fedora/noid/version'

Gem::Specification.new do |spec|
  spec.name          = "active_fedora-noid"
  spec.version       = ActiveFedora::Noid::VERSION
  spec.authors       = ["Michael J. Giarlo"]
  spec.email         = ["leftwing@alumni.rutgers.edu"]
  spec.summary       = %q{Noid identifier services for ActiveFedora-based applications}
  spec.description   = %q{Noid identifier services for ActiveFedora-based applications.}
  spec.homepage      = "https://github.com/psu-stewardship/active_fedora-noid"
  spec.license       = "Apache2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'active-fedora'
  spec.add_dependency 'noid'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
end
