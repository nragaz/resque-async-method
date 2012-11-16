require 'spec_helper'

describe Resque::Plugins::Async::Method do

  subject { MyKlass.new }
  
  class MyKlass
    include Resque::Plugins::Async::Method
    
    def foo
      'bar'
    end
    async_method :foo
  end

  it { MyKlass.respond_to?(:async_method).should be_true }

  context 'can be call method on sync mode' do
    it { subject.respond_to?(:sync_foo).should be_true }
    it { subject.sync_foo.should eql('bar') }
  end
  
  context 'method should pass on async mode' do
    
    before do
      Rails.env.stub test?: false
      subject.stub persisted?: true, id: 42
      Resque.should_receive(:enqueue).with(Resque::Plugins::Async::Worker, 'MyKlass', 42, :sync_foo).and_return('it works')
    end
    
    its(:foo) { should eql 'it works' }
  end
  
end