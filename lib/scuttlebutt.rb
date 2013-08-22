

module Scuttlebutt


  # Require the logger and set up dummy $log
  require 'scuttlebutt/ui/multilog'

  LOG = Scuttlebutt::UI::MultiOutputLogger.new({}, "sb")

  require 'scuttlebutt/input'
  require 'scuttlebutt/output'
  require 'scuttlebutt/engine'
  require 'scuttlebutt/compiler'
  require 'scuttlebutt/vm'

  VERSION = "0.0.1a"

end
