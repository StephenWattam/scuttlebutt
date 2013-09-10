

module Scuttlebutt

  require 'scuttlebutt/interpreter'
  require 'scuttlebutt/output'

  class VirtualMachine

    # At most retry a row this many times
    MAX_RETRIES = 10

    def initialize(input, output, engine)
      # Store the args
      @input    = input
      @output   = output
      @engine   = engine
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
      system_up(obj)

      count = 0
      while (row = @input.next_row)
        count += 1

        # Loop until we run out of retries or the row completes successfully...
        retries = script.params.retries ? script.params.retries.to_i : MAX_RETRIES
        success = false
        while !success && retries > 0

          # Take one off...
          retries -= 1

          # Tell the output method to start fresh
          @output.start_row

          # Try to run the row
          begin

            # Run the row and say it worked.
            LOG.info "*** Processing input row #{count}#{@input.max ? " of #{@input.max}" : ''} (output: #{@output.count} item[s] complete)"
            process_row(obj, row)
            success = true

          rescue SystemExit, Interrupt
            @output.discard_row 

            LOG.error "Close requested using control-C"
            raise "Caught signal."

          rescue Errno::ECONNREFUSED, EOFError, Interrupt
            @output.discard_row

            # Reconnect if the browser dies
            LOG.error "Connection to browser lost, reconnecting and running pullup..."
            @engine.connect_driver
            system_up(obj)
          rescue StandardError => e
            @output.discard_row

            LOG.error "Error running row #{count}.  Will retry #{retries} more time[s] before giving up."
            LOG.error "The error was: #{e}"
            LOG.debug "#{e.backtrace.join("\n")}"
          end
        end

        # Since it worked, flush the output
        @output.finalise_row
      end

      ##= Script down region call
      system_down(obj)

      return count
    end

  private

    def process_row(obj, row)

      # Wipe row scratch data
      obj.refresh_row_scratch

      # Assigno row to work on
      obj.row = row

      ##= Row up region call
      protected_run(obj, :row_up)

      ##= Row down region call
      protected_run(obj, :row_down)
    end

    def system_up(obj)
      protected_run(obj, :system_up)
    end


    def system_down(obj)
      protected_run(obj, :system_down)
    end


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
