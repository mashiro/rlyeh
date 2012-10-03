module Rlyeh
  module Once
    def once(&block)
      unless @_once_flag 
        block.call if block
        @_once_flag = true
      end
    end
  end
end
