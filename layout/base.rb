module Layout
  class Base
    def initialize(options)
      @rows = options.delete(:rows)
      @cols = options.delete(:cols)
      @options = options
    end
  end
end
