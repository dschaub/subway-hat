class TerminalDisplay
  attr_accessor :rotation, :brightness

  Color = Struct.new(:r, :g, :b)

  def initialize
    @grid = []
  end

  def []=(x, y, color)
    @grid[y] = [] unless @grid[y]
    @grid[y][x] = color
  end

  def clear(and_show = true)
    puts "Clearing (and show = #{and_show})"
  end

  def show
    puts format_grid
    puts "Brightness = #{brightness}"
    puts "Rotation = #{rotation}"
    puts "--------------------------"
  end

  private

  def format_grid
    @grid.map do |row|
      row.map do |col|
        if col.r == 0 && col.g == 0 && col.b == 0
          '.'
        elsif col.r == 0xFF && col.g == 0xFF && col.b == 0xFF
          'O'
        else
          '='
        end
      end.join(' ')
    end.join("\n")
  end
end
