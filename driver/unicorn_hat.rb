module Driver
  class UnicornHat
    delegate :[]=, :clear, :rotation=, :rotation, :brightness=, :brightness, :show,
      to: :unicorn_hat

    def initialize
      require 'ws2812'
    end

    def get_color(r, g, b)
      Ws2812::Color.new(r, g, b)
    end

    def rows
      8
    end

    def cols
      8
    end

    private

    def unicorn_hat
      @unicorn_hat ||= Ws2812::UnicornHAT.new
    end
  end
end
