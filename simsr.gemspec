# -*- encoding: utf-8 -*-
require File.expand_path('../lib/simsr/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["wursttheke"]
  gem.email         = ["philipp@rudirockt.de"]
  gem.description   = "Deliver Text Messages"
  gem.summary       = "Send SMS messages through proprietary SMS Gateway Services via HTTP Get Requests"
  gem.homepage      = "http://www.rudirockt.de"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "simsr"
  gem.require_paths = ["lib"]
  gem.version       = Simsr::VERSION
  
  #gem.add_dependency('activesupport', '>= 3.2.0')
  gem.add_runtime_dependency 'rails', '~> 3.2'
  gem.add_development_dependency 'rspec', '~> 2.6'
  #gem.add_development_dependency 'ammeter', '~> 0.1.3'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'mysql2', '~> 0.3.7'
  gem.add_development_dependency 'pg'
  #gem.add_development_dependency 'guard'
  #gem.add_development_dependency 'guard-rspec'
end
