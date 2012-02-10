# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rlyeh/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["mashiro"]
  gem.email         = ["mail@mashiro.org"]
  gem.description   = %q{Welcome to the deep sea}
  gem.summary       = %q{IRC gateway server framework}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rlyeh"
  gem.require_paths = ["lib"]
  gem.version       = Rlyeh::VERSION

  gem.add_dependency 'ircp'
  gem.add_dependency 'eventmachine'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
