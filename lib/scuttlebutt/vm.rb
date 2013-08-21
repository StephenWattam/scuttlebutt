

module Scuttlebutt

  require 'scuttlebutt/interpreter'

  class VirtualMachine
    def initialize(data_src, code_class, engine)
      # Store the args
      @src      = data_src
      @cls      = code_class
      @engine   = engine

      # Progress
      @count    = 0
    end

    # Run over the input data, calling stuff as appropriate
    def run(status_callback = nil)
      obj = @cls.new(@engine, status_callback)

      # Say we're starting
      obj.start_time = Time.now

      ##= Script up region call.
      obj.system_up

      while (row = @src.next_row)
        yield(@count, row) if block_given?

        # Assign row to work on
        obj.row = row

        ##= Row up region call
        obj.row_up

        ##= Row down region call
        obj.row_down

        puts "--> DATA -- #{obj.data}"
        @count += 1
      end

      ##= Script down region call
      obj.system_down

      return @count
    end

  end
end
