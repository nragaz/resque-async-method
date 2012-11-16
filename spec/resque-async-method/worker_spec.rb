require 'spec_helper'

describe Resque::Plugins::Async::Worker do
  
  subject { Resque::Plugins::Async::Worker }
  
  context 'queue' do
    describe 'should have default value' do
      pending('method_spec.rb override default value') do
        its(:queue) { should eql :async_methods }
      end
    end
    context 'should be change of value' do
      before { subject.queue = :foo }
      describe 'when set :foo' do
        its(:queue) { should eql :foo }
      end
    end
  end
  
  class MyClass; end
  
  context '#perform' do
    let(:my_class_instance) { MyClass.new }
    before do
      MyClass.should_receive(:find).with(42).and_return(my_class_instance)
      my_class_instance.should_receive(:foo).with('bar')
    end
    it('should be call corretly Resque#perform') { subject.perform('MyClass', 42, 'foo', 'bar') }
  end

end