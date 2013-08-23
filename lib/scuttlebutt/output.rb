
module Scuttlebutt::Output
 

  class OutputMethod
 

    attr_reader :count

    def initialize
      @count = 0
    end

    # Submit data to the output method.
    def finalise(row)
      puts "STUB: finalise in Scuttlebutt::Output::OutputMethod"
      count += 1
    end

    # Return the amount of cached items that have yet to be output
    def cached_data
      return 0
    end
    
    # How many items are on this row?
    def row_count
      return 0
    end

    # Force output of cache
    def flush 
      puts "STUB: output in Scuttlebutt::Output::OutputMethod"
    end

    # start caching for a given row
    def start_row
      puts "STUB: start_row in Scuttlebutt::Output::OutputMethod"
    end

    # Discard the last row's worth of data
    def discard_row
      puts "STUB: discard_row in Scuttlebutt::Output::OutputMethod"
    end

    # Finalise the row's worth of data
    def finalise_row 
      puts "STUB: finalise_row in Scuttlebutt::Output::OutputMethod"
    end

    # Close all resources.
    def close
    end
  end

  require 'scuttlebutt/output/csv_output'

end
