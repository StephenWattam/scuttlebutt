

module Scuttlebutt::Interpreter

  # Require extra API modules here.
  require 'scuttlebutt/interpreter/interface'
  require 'scuttlebutt/interpreter/time'
  # require 'scuttlebutt/interpreter/lookup'
  # require 'scuttlebutt/interpreter/output'


  # Creates a new subclass of the interpreterbasis class,
  # for modification to create an interpreter object.
  def self.new(libs, regions)
    cls = Class.new(Scuttlebutt::Interpreter::InterpreterBasis)

    regions.each do |name, code|

      # TODO: define libs somehow (perhaps using a module?)
      cls.send(:class_eval, libs)

      # Define a new method in the class
      puts "-> Defining method #{name}..."
      cls.send(:define_method, name.to_sym, Proc.new do ||
              begin
                 eval(code)
              rescue StandardError => e
                $stderr.puts "*** Exception in script, region #{name}."
                $stderr.puts "    #{e}"
                $stderr.puts "    #{e.backtrace.join("\n    ")}"
              end
      end ) # /cls.send

    end # /regions.each 

    return cls
  end



  # The basis of all interpreted code in the system.
  #
  # Should contain any module-less API calls, and all data
  class InterpreterBasis < Object

    require 'ostruct'

    attr_accessor :data, :start_time

    # Create a new Interpreter
    #
    # output_obj must subclass Scuttlebutt::Output::OutputMethod
    def initialize(engine, output_obj, status_callback = nil)
      @e              = engine
      @row            = nil
      @start_time     = nil
      @status_callback = status_callback 
      @output_obj     = output_obj

      # For temp variables.
      @s_scratch        = OpenStruct.new
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

    # Present output finally to the output method.
    def push_output(row)
      row = row.marshal_dump if row.is_a?(OpenStruct)
      raise "Output objects must be of class Hash or OpenStruct.  If in doubt use new_output_row() to get one." unless row.is_a?(Hash)
      @output_obj.finalise(row)
    end

    # Returns a new output row to be filled out
    def new_output_row
      return OpenStruct.new
    end

    # TODO: loads of helpers and such
   
    def status(str)
      if @status_callback
        @status_callback.call(str) 
      else
        puts str.to_s
      end
    end

    # Attempt to do something, but hush failure, optionally
    # providing a default value
    def try(default = nil, *args, &block)
      begin
        return yield
      rescue StandardError => e
        if args.length > 0
          raise e if not args.include?(e.class)
        end
      end
      return default
    end

  end

end
