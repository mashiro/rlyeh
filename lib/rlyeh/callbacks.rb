module Rlyeh
  module Callbacks
    [:before, :around, :after].each do |sym|
      class_eval <<-METHOD
        def #{sym}_callbacks
          @#{sym}_callbacks ||= Hash.new { |hash, key| hash[key] = [] }
        end

        def #{sym}(name, &block)
          #{sym}_callbacks[name.to_s] << block
        end
      METHOD
    end

    def run_callbacks(name, *args, &block)
      fire = proc { |c| c.call *args }

      before_callbacks[name.to_s].each(&fire)
      around_callbacks[name.to_s].each(&fire)

      result = block.call *args if block

      around_callbacks[name.to_s].each(&fire)
      after_callbacks[name.to_s].each(&fire)

      result
    end
  end
end

