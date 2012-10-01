require 'spec_helper'

describe Rlyeh::Attributes do
  class Env
    include Rlyeh::Attributes
    attr_reader :attributes

    def initialize
      @attributes = Hash.new('default')
    end
  end

  before do
    @env = Env.new
    @env.foo = 1
    @env.bar = 2
  end
  subject { @env }

  describe '#attributes' do
    subject { @env.attributes }
    it { should be_kind_of ::Hash }
  end

  describe '#read_attribute' do
    it { subject.read_attribute(:foo).should eq 1 }
    it { subject.read_attribute(:bar).should eq 2 }
    it { subject.read_attribute(:buzz).should eq 'default' }
  end

  describe '#write_attribute' do
    context 'foo' do
      before { subject.write_attribute 'foo', 'value' }
      it { subject.attributes['foo'].should eq 'value' }
    end

    context 'buzz' do
      before { subject.write_attribute 'buzz', 'value' }
      it { subject.attributes['buzz'].should eq 'value' }
    end
  end
  
  describe '#respond_to?' do
    it { should be_respond_to :foo }
    it { should be_respond_to :bar }
    it { should be_respond_to :buzz }
  end

  describe '#method_missing' do
    context 'get' do
      its(:foo) { should eq 1 }
      its(:bar) { should eq 2 }
      its(:buzz) { should eq 'default' }
    end

    context 'set' do
      context 'foo' do
        before { subject.foo = 'value' }
        it { subject.attributes['foo'].should eq 'value' }
      end
      
      context 'buzz' do
        before { subject.buzz = 'value' }
        it { subject.attributes['buzz'].should eq 'value' }
      end
    end

    context 'has' do
      it { should be_foo }
      it { should be_bar }
      it { should_not be_buzz }
    end
  end
end
