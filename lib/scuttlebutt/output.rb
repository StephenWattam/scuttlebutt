
module Scuttlebutt::Output
 

  class OutputMethod
  
    def initialize
    end

    # Submit data to the output method.
    def finalise(row)
      puts "STUB: finalise in Scuttlebutt::Output::OutputMethod"
    end

    # Return the amount of cached items that have yet to be output
    def cached_data
      return 0
    end

    # Force output of cache
    def output
      puts "STUB: output in Scuttlebutt::Output::OutputMethod"
    end
  end

  require 'scuttlebutt/output/csv_output'

end
