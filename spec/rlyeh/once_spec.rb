require 'spec_helper'

describe Rlyeh::Once do
  class Cthulhu
    include Rlyeh::Once
    attr_reader :count

    def initialize
      @count = 0
    end

    def summon
      once do
        @count += 1
      end
      self
    end
  end

  describe '#once' do
    before { @cthulhu = Cthulhu.new }
    subject { @cthulhu }

    it { subject.count.should eq 0 }
    it { subject.summon.count.should eq 1 }
    it { subject.summon.summon.count.should eq 1 }
    it { subject.summon.summon.summon.count.should eq 1 }
  end
end
