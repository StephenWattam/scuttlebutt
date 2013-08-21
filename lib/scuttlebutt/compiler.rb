

module Scuttlebutt

  require 'scuttlebutt/interpreter'
  include Scuttlebutt::Interpreter

  class ScriptCompiler

    REGION_START = /^\s*##=\s*(?<region_name>[a-z0-9\_\-]+)\s*$/

    def initialize(file)
      @filename = file
    end

    # Compile an SBS file into a ruby object
    # that handles state and the Scuttlebutt engine
    def compile
      syntax_check

      libs, regions = load_code_regions

      puts "Found #{regions.length} code region[s]."

      cls = build_class(libs, regions)

      return cls
    end

    private

    # Load code regions from a file, 
    # and return a hash of them, along with a listing for
    # the special "libs" listing.
    def load_code_regions
      regions = {}
     
      # Count up lines by region, interpreting the ##= syntax.
      current_region = :__lib__
      f = File.open(@filename, 'r')

      # Iterate over lines
      f.each_line do |line|
        line.chomp!

        # Region header
        if (m = line.match(REGION_START))
          current_region = m['region_name']
        # Add code to the last region
        else
          regions[current_region] = [] if not regions[current_region]
          regions[current_region] << line
        end # if

      end # each_line
      f.close

      # Then stitch them all together
      regions.keys.each { |k| regions[k] = regions[k].join("\n") }

      # Lastly, remove the special region "libs"
      libs = regions.delete(:__lib__)
      return libs, regions
    end
  

    # Construct a class that interprets data
    def build_class(libs, regions)
      # TODO: 1) check regions have actual data in them...
      #       2) Have a list of allowed regions and check people aren't clobbering things

      # Next up, generate an object from them
      cls = Scuttlebutt::Interpreter.new(libs, regions)

      return cls
    end



    # Perform a syntax check
    def syntax_check
      $stderr.puts "STUB: syntex_check in Scuttlebutt::ScriptCompiler for file #{@filename}"
    end
  end

end

