require './display_manager'
require './options'

if __FILE__ == $0
  options = Options.new(ARGV).parse!
  manager = DisplayManager.new(options)
  manager.run!
end
