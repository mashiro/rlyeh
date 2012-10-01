require 'spec_helper'

describe Rlyeh::Environment do
  before do
    @env = Rlyeh::Environment.new
    @env.foo = Rlyeh::Environment.new
    @env.foo.bar = 'buzz'
  end
  subject { @env }

  describe '#extract' do
    it { subject.extract(:foo).should eq @env.foo }
    it { subject.extract(:foo, :bar).should eq @env.foo.bar }
    it { lambda { subject.extract(:foo, :bar, :buzz) }.should raise_error NoMethodError }
  end
end
