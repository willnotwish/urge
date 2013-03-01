# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'urge/version'

Gem::Specification.new do |gem|
  gem.name          = "urge"
  gem.version       = Urge::VERSION
  gem.authors       = ["Nick Adams"]
  gem.email         = ["nadams@dsc.net"]
  gem.description   = %q{Urges an object to take some form of action, on a timed basis}
  gem.summary       = %q{Urges action}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency( 'activerecord' )
  gem.add_dependency( 'aasm' )
  gem.add_dependency( 'logging' )
  
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'factory_girl'
  
end
