# -*- encoding: utf-8 -*-
require File.expand_path('../lib/resque-async-method/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Nick Ragaz', 'Joel AZEMAR']
  gem.email         = ['nick.ragaz@gmail.com', 'joel.azemar@gmail.com']
  gem.description   = %q{Make Active Support instance methods asynchronous using resque.}
  gem.summary       = %q{Make Active Support instance methods asynchronous using resque.}
  gem.homepage      = 'http://github.com/nragaz/resque-async-method'
  # gem.homepage    = 'http://github.com/joel/resque-async-method'
  gem.licenses      = [ 'MIT' ]
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = 'resque-async-method'
  gem.require_paths = ['lib']
  gem.version       = ResqueAsyncMethod::VERSION

  gem.add_runtime_dependency 'resque'
  gem.add_runtime_dependency 'activesupport'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
end