

module Scuttlebutt::Interpreter

  require 'ostruct'


  # Require extra API modules here.
  require 'scuttlebutt/interpreter/interface'
  require 'scuttlebutt/interpreter/time'
  # require 'scuttlebutt/interpreter/debug'
  # require 'scuttlebutt/interpreter/lookup'
  # require 'scuttlebutt/interpreter/output'

  require 'scuttlebutt/messages'

  # Creates a new subclass of the interpreterbasis class,
  # for modification to create an interpreter object.
  def self.new(params, code)
    cls = Class.new(Scuttlebutt::Interpreter::InterpreterBasis)

    # Add all the defined code
    cls.send(:class_eval, code)

    cls.send(:define_method, :params, Proc.new do
      return OpenStruct.new(params)
    end)

    # Set the parameters as a read-only method
    cls.singleton_class.class_eval do
      define_method(:params) do ||
        return params
      end
    end

    return cls
  end

  # The basis of all interpreted code in the system.
  #
  # Should contain any module-less API calls, and all data
  class InterpreterBasis < Object

    require 'securerandom'

    include Scuttlebutt::Messages 

    attr_accessor :data, :start_time

    # Create a new Interpreter
    #
    # output must subclass Scuttlebutt::Output::OutputMethod
    def initialize(log, engine, output)
      @e              = engine
      @row            = nil
      @start_time     = nil
      @output         = output

      # The constant is unavailable here...
      @log            = log

      # For temp variables.
      @s_scratch      = OpenStruct.new
      @sequential_id  = 0
    end

    # - overridden later -
    def system_up;    end
    def system_down;  end
    def row_up;       end
    def row_down;     end

    # Create a blank scratch for people to store things in.
    def refresh_row_scratch
      @scratch = OpenStruct.new
    end

    # Store the current row as a struct for easier access.
    def row=(row)
      @row = OpenStruct.new(row.to_hash)
    end

    private

  
    # Access the current row without using @
    def row
      @row
    end

    # Get a sequential ID
    def seq_id
      @sequential_id += 1
      return @sequential_id
    end

    # Generate a UUID
    def uuid
      SecureRandom.uuid
    end

    # Per-row scratch storage
    def scratch
      @scratch
    end

    # Start a debug console
    def debug_console(binding = binding)
      @log.info "Debug console.  Press ^D to continue."

      # Format the trace nicely for people
      trace = caller
      trace.map! do |t|
        if m = t.match(/^\(eval\):(?<line>[0-9]+):in.*`(?<proc>.+)'/)
          "line #{m['line']} in #{m['proc']}"
        else
          nil
        end
      end
      trace.delete(nil)

      # output
      @log.info "Here's a handy trace of where you were in the script:"
      trace.each { |t| @log.info "  #{t}" }

      require 'pry'

      Pry.config.pager = false
      Pry.config.prompt = proc { |obj, nest_level, _| "[#{nest_level}]sbdb> " }

      # TODO: See if you can auto-pry on the caller rather than relying on the binding passed in
      # puts "--> #{caller}"

      binding.pry
    end

    # Present output finally to the output method.
    def push_output(row)
      @log.debug "Pushing data point #{@output.row_count + 1}/row (#{@output.count + 1} total)"# #{row}"
      @log.debug "Payload: #{row}"


      row = row.marshal_dump if row.is_a?(OpenStruct)
      raise "Output objects must be of class Hash or OpenStruct.  If in doubt use new_output_row() to get one." unless row.is_a?(Hash)
      @output.finalise(row)

    rescue StandardError => e
      @log.error "Error writing output: #{e}"
      @log.debug "#{e.backtrace.join("\n")}"
    end

    # Returns a new output row to be filled out
    def new_output_row
      return OpenStruct.new
    end

    # Wait for a given period of time
    # Usually it's better to wait *for* something to happen using
    # conditional waits in the browser driver...
    def delay(sec, max = nil)
      sec = sec + (rand * (max - sec)) if max && max > sec_or_min
      @log.debug "Delaying for #{sec.round(2)}s"
      sleep(sec)
    end

    # TODO: loads of helpers and such

    def warn(str)
      @log.warn("[SW] #{str}")
    end

    def debug(str)
      @log.debug("[SD] #{str}")
    end

    def status(str)
      @log.info("[SI] #{str}")
    end

    # Attempt to do something, but hush failure, optionally
    # providing a default value
    def try(default = nil, *args, &block)
      begin
        return yield
      rescue StandardError => e
        @log.debug "try{} failure: #{e}"
        if args.length > 0
          raise e unless args.include?(e.class)
        end
      end
      return default
    end

    # Attempt something, but quit quietly if it fails.
    def tryquit(*classes_to_catch)
      begin
        yield
      rescue StandardError => e
        @log.debug "tryquit{} failure: #{e}"
        if classes_to_catch.length > 0
          raise e unless classes_to_catch.include?(e.class)
        else
          raise PlannedFailure.new
        end
      end
    end 

  end

end
