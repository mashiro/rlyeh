require 'spec_helper'

describe Rlyeh::Environment do
  before do
    @env = Rlyeh::Environment.new
    @env.foo = 1
    @env.bar = 2
  end
  subject { @env }
  
  describe '#respond_to?' do
    it { should be_respond_to :foo }
    it { should be_respond_to :bar }
    it { should_not be_respond_to :buzz }
  end

  describe '#method_missing' do
    context 'fetch' do
      its(:foo) { should eq 1 }
      its(:bar) { should eq 2 }
      it { lambda { subject.buzz }.should raise_error NoMethodError }
    end

    context 'assign' do
      context 'foo' do
        before { subject.foo = 'assigned' }
        its(:foo) { should eq 'assigned' }
      end
      
      context 'buzz' do
        before { subject.buzz = 'assigned' }
        its(:buzz) { should eq 'assigned' }
      end
    end

    context 'has' do
      it { should be_foo }
      it { should be_bar }
      it { should_not be_buzz }
    end
  end
end
