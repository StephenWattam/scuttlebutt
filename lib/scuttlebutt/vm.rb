

module Scuttlebutt

  require 'scuttlebutt/interpreter'
  require 'scuttlebutt/output'

  class VirtualMachine
    def initialize(input, output, engine)
      # Store the args
      @input    = input
      @output   = output
      @engine   = engine

      # Progress
      @count    = 0
    end

    # Run over the input data, calling stuff as appropriate
    def run(script)
      LOG.info "Running job"


      LOG.debug "Instantiating interpreter object..."
      script.instantiate(LOG, @engine, @output)
      obj = script.instance

      # Say we're starting
      obj.start_time = Time.now

      ##= Script up region call.
      protected_run(obj, :system_up)

      while (row = @input.next_row)
        LOG.info "Processing row #{@count}"

        # Wipe row scratch data
        obj.refresh_row_scratch

        # Assigno row to work on
        obj.row = row

        ##= Row up region call
        protected_run(obj, :row_up)

        ##= Row down region call
        protected_run(obj, :row_down)

        @count += 1
      end

      ##= Script down region call
      protected_run(obj, :system_down)

      return @count
    end

  private

    # Execute a call on the interpreter,
    # whilst handling messages and exceptions in a nice way.
    def protected_run(obj, method, *args)
      LOG.debug "Running #{method} with #{args.length} arguments"

      obj.send(method, *args)
    rescue Scuttlebutt::Messages::PlannedFailure
      # Fine by us.
    end

  end
end
