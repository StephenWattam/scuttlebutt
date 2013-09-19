

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

    # Check the scuttlebutt version against the script
    def check_version(current)
      require 'versionomy'

      min = Versionomy.parse(params.min_version)
      current = Versionomy.parse(VERSION)
      if current < min 
        LOG.fatal "This script requires version #{params.min_version} or above, but this is Scuttlebutt version #{VERSION}."
        exit(1)
      end

      if params.max_version
        max = Versionomy.parse(params.maxver_version)
        if current > max
          LOG.fatal "This script doesn't work with versions over #{params.max_version}, but this is Scuttlebutt version #{VERSION}."
          exit(1)
        end
      end
    end


  end

  # Compile a script (text) into a Script (object)
  class ScriptCompiler

    SYN_COMMENT       = /^\s*#(?<comment>.*)$/
    SYN_BEGIN_PARAMS  = /^\s*--\s+parameters\s+--\s*$/
    SYN_END_PARAMS    = /^\s*--\s+end\s+--\s*$/

    SYN_PARAMS        = /^\s*(?<list>\*)?(?<key>[a-z][a-z_0-9]*):(?<value>.+)$/


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

            # If it's a list, keep it as an array
            if m['list'] then
              params[key]  = [] if not params[key]
              params[key] += Shellwords.shellwords(m['value'])
            else
              value = m['value'].to_s.strip
              params[key] = ((value.length > 0) ? value : true)
            end

            LOG.debug "Parameter: #{key}#{value.is_a?(Array) ? ' (list)' : ''}, value: #{value}"
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
      LOG.warn "STUB: syntax_check in Scuttlebutt::ScriptCompiler for file #{filename}"
    end
  end

end

