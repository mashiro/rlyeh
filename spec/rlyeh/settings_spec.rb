require 'spec_helper'

describe Rlyeh::Settings do
  describe '#settings' do
    class Test
      include Rlyeh::Settings
    end
    
    context 'class' do
      subject { Test }
      its(:settings) { should eq Test }
    end

    context 'instance' do
      subject { Test.new }
      its(:settings) { should eq Test }
    end
  end
  
  describe '#set' do
    class Test
      include Rlyeh::Settings
      set :logging, false
      set :default_encoding, 'utf-8'
    end
    subject { Test.settings }
    
    context 'getter' do
      its(:logging) { should eq false }
      its(:default_encoding) { should eq 'utf-8' }
    end
    
    context 'setter' do
      before { Test.settings.logging = true }
      its(:logging) { should eq true }
    end
    
    context 'condition' do
      before { Test.settings.logging = false }
      it { should_not be_logging }
    end

    context 'no method' do
      it { lambda { Test.settings.not_found }.should raise_error(NoMethodError) }
    end
    
    context 'multi set' do
      before { Test.set :foo => 1, :bar => 2, :buzz => 'zzz' }
      its(:foo) { should eq 1 }
      its(:bar) { should eq 2 }
      its(:buzz) { should eq 'zzz' }
    end
  end
end
