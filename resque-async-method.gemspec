Gem::Specification.new do |s|
  s.name = "resque-async-method"
  s.summary = "Make Active Record instance methods asynchronous using resque."
  s.description = "Make Active Record instance methods asynchronous using resque."
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.version = "1.0.0"
  s.authors = ["Nick Ragaz"]
  s.email = "nick.ragaz@gmail.com"
  s.homepage = "http://github.com/nragaz/resque-async-method"
  
  s.add_dependency 'resque'
  s.add_dependency 'activesupport'
  
  s.add_development_dependency 'sqlite3'
end
