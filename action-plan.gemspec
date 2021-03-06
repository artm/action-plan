# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'action/plan/version'

Gem::Specification.new do |spec|
  spec.name          = "action-plan"
  spec.version       = Action::Plan::VERSION
  spec.authors       = ["Artem Baguinski"]
  spec.email         = ["abaguinski@depraktijkindex.nl"]

  spec.summary       = %q{Plan and eventually execute actions}
  spec.homepage      = "https://github.com/artm/action-plan"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"

  spec.add_dependency "activesupport", "> 4.0"
  spec.add_dependency "wisper", "~> 2.0.0.rc1"
end
