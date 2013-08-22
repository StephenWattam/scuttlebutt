

module Scuttlebutt

  require 'shellwords'

  require 'scuttlebutt/interpreter'
  include Scuttlebutt::Interpreter

  # Represents a script in the system.
  # Used to keep track of what is instantiated and where
  class Script

    require 'ostruct'

    attr_reader :filename, :params, :cls, :instance

    def initialize(filename, params, cls)
      @filename   = filename
      @params     = OpenStruct.new(params)
      @cls        = cls

      @instance   = nil
    end

    def instantiate(log, engine, output)
      @instance   = cls.new(log, engine, output)
    end
  
    # Check the output format fits
    def check_output(output)
      if !params.output_fields
        LOG.warn "Warning.  No output list is specified in #{filename}."
        LOG.warn "          I will continue, but the output will have to be built on-the-fly"
        LOG.warn "          This usually uses more RAM."
        return
      end
    end

    # Check the input CSV fields are sufficient
    def check_input(input)
      if !params.input_fields
        LOG.warn "Warning.  No input fields are specified in #{filename}."
        LOG.warn "          I will continue, but the input file might not match the script."
        return
      end

      require 'set'

      if !Set.new(params.input_fields).subset?(Set.new(input.fields))
        LOG.fatal "This script requires fields the input (#{input.filename}) does not provide."
        LOG.fatal "Fields required: #{params.input_fields.join(', ')}"
        LOG.fatal "Fields provided: #{input.fields.join(', ')}"
        LOG.fatal "Fields missing: #{(params.input_fields - input.fields).join(', ')}"
        raise "Insufficient input fields to run #{filename}."
      end
    end

  end

  # Compile a script (text) into a Script (object)
  class ScriptCompiler

    SYN_COMMENT       = /^\s*#(?<comment>.*)$/
    SYN_BEGIN_PARAMS  = /^\s*--\s+parameters\s+--\s*$/
    SYN_END_PARAMS    = /^\s*--\s+end\s+--\s*$/

    SYN_PARAMS        = /^\s*(?<key>[a-z][a-z_0-9]*):(?<value>.+)$/


    # Compile an SBS file into a ruby object
    # that handles state and the Scuttlebutt engine
    def self.compile(filename)
      syntax_check(filename)

      params, code = load_code(filename)

      # puts "Found #{regions.length} code region[s]."

      cls = Scuttlebutt::Interpreter.new(params, code)

      return Script.new(filename, params, cls)
    end

    private

    # Load code regions from a file, 
    # and return a hash of them, along with a listing for
    # the special "libs" listing.
    def self.load_code(filename)
     
      # Somewhere to keep things
      params = {}
      code   = []

      # Count up lines and take into account param blocks
      f = File.open(filename, 'r')

      # Loop over each item
      in_param_block  = false 
      count           = 0
      f.each_line do |line|
        count += 1
        line.chomp!

        if (m = line.match(SYN_COMMENT))
          
          # Read the comment value
          comment_string = m['comment']

          # Parse comm
          if comment_string =~ SYN_BEGIN_PARAMS
            LOG.debug "Param block start on line #{count}"
            in_param_block = true
          elsif comment_string =~ SYN_END_PARAMS
            LOG.debug "Param block end on line #{count}"
            in_param_block = false
          elsif in_param_block && (m = comment_string.match(SYN_PARAMS))

            key   = m['key'].to_sym
            value = Shellwords.shellwords(m['value'])
            value = true if value.length == 0

            params[key] = value

            LOG.debug "Parameter: #{key}, value: #{value}"
          end

        end # /if

        # Lastly, add to the code listing anyway
        # so the line numbers add up.
        code << line

      end # /f.each_line

      return params, code.join("\n")
    end
  
    # Perform a syntax check
    def self.syntax_check(filename)
      LOG.warn "STUB: syntex_check in Scuttlebutt::ScriptCompiler for file #{filename}"
    end
  end

end

