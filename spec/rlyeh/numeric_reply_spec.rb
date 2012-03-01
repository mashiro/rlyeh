require 'spec_helper'

describe Rlyeh::NumericReply do
  describe '#to_value' do
    [1, '1', '01', '001', 'welcome', :welcome].each do |arg|
      context "with argument #{arg.inspect}" do
        subject { Rlyeh::NumericReply.to_value arg }
        it { should eq '001' }
      end
    end
  end

  describe '#to_key' do
    [1, '1', '01', '001', 'welcome', :welcome].each do |arg|
      context "with argument #{arg.inspect}" do
        subject { Rlyeh::NumericReply.to_key arg }
        it { should eq :welcome }
      end
    end
  end
end
