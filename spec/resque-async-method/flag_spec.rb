require 'spec_helper'

describe Resque::Plugins::Async::Flag do
  class WatchableClass1 ; end
  class WatchableClass2 ; end
  class NonWatchableClass ; end
  
  class TestJobClass
    extend Resque::Plugins::Async::Flag
    flag_enqueued_records [ WatchableClass1, WatchableClass2 ]
  end

  describe '#classes_to_watch' do
    context "with valid values" do
      it "returns the classes to watch" do
        TestJobClass.classes_to_watch.should eql [ WatchableClass1, WatchableClass2 ]
      end
    end
    context "with invalid values" do
      ['invalid', ['invalid', 'value'], [WatchableClass1, 'invalid' ]].each do |invalid_value|
        it "raises an error" do
          expect {
            TestJobClass.class_eval do
              flag_enqueued_records invalid_value
            end
          }.to raise_error
        end
      end
    end
  end

  describe '#flagged?' do
    let(:redis) { mock }
    let(:args) { [ 'WatchableClass1', 12, 'a_method' ] }
    before do
      redis.stub(:exists).with('WatchableClass1|12').and_return 'true_or_false'
      TestJobClass.stub(:redis).and_return redis
    end

    it "returns the redis result of correct query" do
      TestJobClass.flagged?(args).should eql 'true_or_false'
    end
  end

  describe '#flag!' do
    let(:redis) { mock }
    let(:args) { [ 'WatchableClass1', 12, 'a_method' ] }
    before do
      TestJobClass.stub(:redis).and_return redis
    end
    it "creates the correct key" do
      redis.should_receive(:set).with 'WatchableClass1|12', 1
      TestJobClass.flag! args
    end
  end

  describe '#unflag!' do
    let(:redis) { mock }
    let(:args) { [ 'WatchableClass1', 12, 'a_method' ] }
    before do
      TestJobClass.stub(:redis).and_return redis
    end
    it "deletes the correct key" do
      redis.should_receive(:del).with 'WatchableClass1|12'
      TestJobClass.unflag! args
    end
  end

  describe '#redis_key' do
    let(:args) { [ 'WatchableClass2', 13, 'a_method' ] }
    subject { TestJobClass.redis_key args }
    it { should eql 'WatchableClass2|13' }
  end

  describe '#flaggable?' do
    subject { TestJobClass.flaggable? args }
    context "when first param not present in classes_to_watch" do
      let(:args) { [ 'NonWatchableClass', 12, 'a_method_call' ] }
      it { should be_false }
    end
    context "when first param not present in classes_to_watch" do
      let(:args) { [ 'WatchableClass2', 12, 'a_method_call' ] }
      it { should be_true }
    end
  end

  describe '#before_enqueue_flag_record' do
    let(:args) { [ 'array', 'of', 'things'] }
    let(:redis) { mock }
    before do
      redis.stub(:set).and_return true
      TestJobClass.stub(:redis).and_return redis
    end

    subject { TestJobClass.before_enqueue_flag_record *args }
    before { TestJobClass.stub(:flaggable?).and_return flaggable? }

    context "when not flaggable" do
      let(:flaggable?) { false }
      it { should be_true }
    end

    context "when flaggable" do
      let(:flaggable?) { true }
      context "when object was flagged previously" do
        before { TestJobClass.stub(:flagged?).with(args).and_return true }
        it "raises an error" do
          expect {
            subject
          }.to raise_error
        end
      end
      context "when object was not flagged yet" do
        before { TestJobClass.stub(:flagged?).with(args).and_return false }
        it { should be_true }
        it "flags the record" do
          TestJobClass.should_receive(:flag!).with args
          subject
        end
      end
    end
  end
end