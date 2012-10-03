require 'spec_helper'

describe Rlyeh::Callbacks do
  class Worker
    include Rlyeh::Callbacks
    attr_reader :events

    def initialize
      @events = []
    end

    def do(n)
      run_callbacks :do, n do
        @events << :"do#{n}"
      end
    end
  end

  describe '#filter' do
    before do
      @worker = Worker.new
      @worker.before(:do) { |n| @worker.events << 1 * n }
      @worker.before(:do) { |n| @worker.events << 2 * n }
      @worker.after(:do) { |n| @worker.events << 3 * n }
      @worker.after(:do) { |n| @worker.events << 4 * n }
      @worker.do 2
    end
    subject { @worker }

    it do
      subject.events.should eq [2, 4, :do2, 6, 8]
    end
  end
end
