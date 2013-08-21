

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

    attr_accessor :data, :row, :start_time

    # Create a new Interpreter
    def initialize(engine, status_callback = nil)
      @e              = engine
      @data           = nil
      @row            = nil
      @start_time     = nil
      @status_callback = status_callback 
    end

    private

    # TODO: loads of helpers and such
   
    def status(str)
      if @status_callback
        @status_callback.call(str) 
      else
        puts str.to_s
      end
    end

    # Return data from the current row
    def field(field)
      return nil if not @row
      @row[field.to_s]
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
