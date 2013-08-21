

module Scuttlebutt

  require 'scuttlebutt/interpreter'
  require 'scuttlebutt/output'

  class VirtualMachine
    def initialize(data_src, code_class, engine, output)
      # Store the args
      @src      = data_src
      @cls      = code_class
      @engine   = engine
      @output   = output

      # Progress
      @count    = 0
    end

    # Run over the input data, calling stuff as appropriate
    def run(status_callback = nil)
      obj = @cls.new(@engine, @output, status_callback)

      # Say we're starting
      obj.start_time = Time.now

      ##= Script up region call.
      obj.system_up

      while (row = @src.next_row)
        yield(@count, row) if block_given?

        # Wipe row scratch data
        obj.refresh_row_scratch

        # Assign row to work on
        obj.row = row

        ##= Row up region call
        obj.row_up

        ##= Row down region call
        obj.row_down

        @count += 1
      end

      ##= Script down region call
      obj.system_down

      return @count
    end

  end
end
