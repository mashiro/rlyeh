module Rlyeh
  class Channel
    attr_reader :name, :key
    attr_reader :users
    attr_reader :mode, :topic

    def initialize(name, options = {})
      @name = name
      @key = options.fetch(:key)
      @mode = options.fetch(:mode)
      @topic = options.fetch(:topic)
      @users = []
    end
  end
end
