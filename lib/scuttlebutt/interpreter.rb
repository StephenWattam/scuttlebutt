

module Scuttlebutt::Interpreter



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

    require 'ostruct'
    include Scuttlebutt::Messages 

    attr_accessor :data, :start_time

    # Create a new Interpreter
    #
    # output must subclass Scuttlebutt::Output::OutputMethod
    def initialize(log, engine, output)
      @e              = engine
      @row            = nil
      @start_time     = nil
      @output     = output

      # The constant is unavailable here...
      @log        = log

      # For temp variables.
      @s_scratch        = OpenStruct.new
    end

    def system_up
    end

    def system_down
    end

    def row_up
    end

    def row_down
    end


    # Create a blank scratch for people to store things in.
    def refresh_row_scratch
      @r_scratch = OpenStruct.new
    end

    # Store the current row as a struct for easier access.
    def row=(row)
      @row = OpenStruct.new(row.to_hash)
    end

    private

    def debug(name = nil)
      @log.info "Starting debug console.  Press ^D to quit."
      require 'pry'
      str = "sbdb"
      str += "/#{name}" if name
      Pry.config.prompt = proc { |obj, nest_level, _| "#{str}/#{nest_level}> " }
      pry
    end

    # Present output finally to the output method.
    def push_output(row)
      @log.debug "Outputting row."

      row = row.marshal_dump if row.is_a?(OpenStruct)
      raise "Output objects must be of class Hash or OpenStruct.  If in doubt use new_output_row() to get one." unless row.is_a?(Hash)
      @output.finalise(row)
    end

    # Returns a new output row to be filled out
    def new_output_row
      return OpenStruct.new
    end

    # TODO: loads of helpers and such
   
    def status(str)
      @log.info(str.to_s)
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
