

module Scuttlebutt::Messages


  # Thrown when something is likely to go wrong and does.
  # It's a non-deadly way of quitting.
  class PlannedFailure < Exception 
  end


  class UnplannedFailure < Exception
  end

end
