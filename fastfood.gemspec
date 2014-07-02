# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastfood/version'

Gem::Specification.new do |spec|
  spec.name          = "fastfood"
  spec.version       = "#{Fastfood::VERSION}"
  spec.authors       = ["Paul Alexander"]
  spec.email         = ["me@phallguy.com"]
  spec.summary       = %q{Because sometimes you just gotta eat and don't have time for chefs.}
  spec.description   = %q{Fastfood is a collection of recipes and tasks for capistrano 3
for provisioning servers. It was created in response to the daunting task of
setting up Chef to provision just a few servers for a small project.}
  spec.homepage      = "https://github.com/phallguy/fastfood"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2'

  spec.add_dependency 'capistrano', '~> 3.0'
  spec.add_dependency 'hashie', '~> 2.1.2'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", '~> 10'
  spec.add_development_dependency "rspec", '~> 3.00'
end
