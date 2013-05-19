# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chatroom-models/version'

Gem::Specification.new do |gem|
  gem.name          = "chatroom-models"
  gem.version       = Chatroom::Models::VERSION
  gem.authors       = ["ShiningRay"]
  gem.email         = ["tsowly@hotmail.com"]
  gem.description   = %q{Basic models for building a chatroom}
  gem.summary       = %q{Basic models for building a chatroom}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency "ohm"
  gem.add_runtime_dependency 'multi_json'
end
