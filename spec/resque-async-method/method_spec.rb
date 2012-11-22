require 'spec_helper'

describe Resque::Plugins::Async::Method do

  context 'for valid record' do
    
    subject { MyKlass.new }
    
    before { Rails.env.stub test?: false }
    
    context 'with simple class' do
      
      class MyKlass
        include Resque::Plugins::Async::Method
    
        def foo
          'bar'
        end
        async_method :foo
        
        def persisted?
          true
        end
        
        def id
          42
        end
      end

      it { MyKlass.respond_to?(:async_method).should be_true }

      context 'have defalut value' do
        it { Resque::Plugins::Async::Worker.queue.should eql(:async_methods) }
        it { Resque::Plugins::Async::Worker.loner.should be_false }
        it { Resque::Plugins::Async::Worker.lock_timeout.should eql(0) }
      end
      
      context 'alsways can be call method on sync mode' do
        it { subject.respond_to?(:sync_foo).should be_true }
        it { subject.sync_foo.should eql('bar') }
      end
  
      context 'and on async mode' do
    
        before do
          Resque.should_receive(:enqueue).with(Resque::Plugins::Async::Worker, 'MyKlass', 42, :sync_foo).and_return('it works')
        end
    
        its(:foo) { should eql 'it works' }
        
      end
      
    end  

  end
end