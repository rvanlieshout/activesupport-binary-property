Gem::Specification.new do |s|
  s.name        = "activesupport-binary-property"
  s.version     = "0.0.1"
  s.summary     = "ActiveSupport::Concern that provides an enum-like functionality for multiple values"
  s.description = "ActiveSupport::Concern that provides an enum-like functionality that for when multiple values are allowed in a method named `has_binary_property`"
  s.authors     = ["Rene van Lieshout"]
  s.email       = "rene@lico.nl"
  s.files       = ["lib/activesupport-binary-property.rb", "lib/activesupport-binary-property/binary_property.rb"]
  s.homepage    = "https://github.com/rvanlieshout/activesupport-binary-property"
  s.license     = "MIT"

  s.add_dependency "rails", ">= 5.0.0"
  s.add_development_dependency 'rspec-rails'
end
