# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "atoship"
  spec.version       = "1.0.0"
  spec.authors       = ["atoship"]
  spec.email         = ["developers@atoship.com"]

  spec.summary       = "Official Ruby SDK for atoship API"
  spec.description   = "A comprehensive Ruby client library for the atoship shipping and logistics API"
  spec.homepage      = "https://github.com/atoship-LLC/atoship-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/atoship-LLC/atoship-ruby"
  spec.metadata["documentation_uri"] = "https://atoship.com/docs"

  spec.files = Dir.glob("{lib,exe}/**/*") + %w[README.md LICENSE Gemfile]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 2.0"
  spec.add_dependency "multi_json", "~> 1.15"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "yard", "~> 0.9"
end