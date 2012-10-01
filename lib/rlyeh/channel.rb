module Rlyeh
  class Channel
    attr_reader :name, :key
    attr_reader :users
    attr_reader :mode, :topic

    def initialize(name, options = {})
      @name = name
      @key = options[:key]
      @mode = options[:mode]
      @topic = options[:topic]
      @users = []
    end
  end
end
