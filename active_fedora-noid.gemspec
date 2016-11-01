# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_fedora/noid/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_fedora-noid'
  spec.version       = ActiveFedora::Noid::VERSION
  spec.authors       = ['Michael J. Giarlo']
  spec.email         = ['leftwing@alumni.rutgers.edu']
  spec.summary       = 'Noid identifier services for ActiveFedora-based applications'
  spec.description   = 'Noid identifier services for ActiveFedora-based applications.'
  spec.homepage      = 'https://github.com/projecthydra/active_fedora-noid'
  spec.license       = 'Apache2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.add_dependency 'active-fedora', '>= 9.7', '< 12'
  spec.add_dependency 'noid', '~> 0.9'
  spec.add_dependency 'rails', '>= 4.2.7.1', '< 6'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rubocop', '~> 0.42.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.5'
  spec.add_development_dependency 'engine_cart', '~> 1.0'
end
