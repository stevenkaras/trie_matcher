# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trie_matcher/version'

Gem::Specification.new do |spec|
  spec.name          = "trie_matcher"
  spec.version       = TrieMatcher::VERSION
  spec.authors       = ["Steven Karas"]
  spec.email         = ["steven.karas@gmail.com"]
  spec.summary       = %q{Fast prefix matching}
  spec.description   = %q{Fast prefix matching using a trie-like structure}
  spec.homepage      = "https://github.com/stevenkaras/trie_matcher"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
