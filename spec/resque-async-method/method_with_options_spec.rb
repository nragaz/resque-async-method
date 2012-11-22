require 'spec_helper'

describe Resque::Plugins::Async::Method do

  context 'for valid record' do
    
    subject { MyAwesomeKlass.new }
    
    before { Rails.env.stub test?: false }
    
    context 'with options' do
      
      before { Resque.stub enqueue: nil }
      
      class MyAwesomeKlass
        include Resque::Plugins::Async::Method
    
        def foo
          'bar'
        end
        async_method :foo, queue: :my_queue,  loner: true, lock_timeout: 60
        
        def persisted?
          true
        end
        
        def id
          42
        end
      end

      context 'should have options values' do
        
        before { subject.foo }
        
        it { Resque::Plugins::Async::Worker.queue.should eql(:my_queue) }
        it { Resque::Plugins::Async::Worker.loner.should be_true }
        it { Resque::Plugins::Async::Worker.lock_timeout.should eql(60) }
      end
      
    end
  end
end