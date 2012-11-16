$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'resque'
require 'active_support/concern'
require 'active_support/inflector'
require 'active_support/dependencies/autoload'
require 'resque-async-method'

RSpec.configure do |config|
  config.mock_with :rspec
end

RSpec.configuration.after(:all) do
  Resque.inline = true
end

# Avoid call Rails.env.test? => false
class Env; def test?; false; end; end
class Rails; def self.env; Env.new; end; end