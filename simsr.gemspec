# -*- encoding: utf-8 -*-
require File.expand_path('../lib/simsr/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["wursttheke"]
  gem.email         = ["philipp@rudirockt.de"]
  gem.description   = "Delivers Short Messages"
  gem.summary       = "Send SMS messagesthrough proprietary SMS Gateway Services via HTTP Get Requests"
  gem.homepage      = "http://www.rudirockt.de"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "simsr"
  gem.require_paths = ["lib"]
  gem.version       = Simsr::VERSION
end
