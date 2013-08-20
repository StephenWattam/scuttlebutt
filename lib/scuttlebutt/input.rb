# Scuttlebutt input library
#
# Currently supports only reading one-line-per-URL lists
#


module Scuttlebutt::Input


  require 'csv'

  class URLSource
    def initialize(filename)
      @filename = filename

      raise "File not found: #{@filename}"    if !File.exist?(@filename)
      raise "File not readable: #{@filename}" if !File.readable?(@filename)

      # Open file handle
      @csv        = CSV.open(@filename, 'r', headers: true)

      # Not at end...
      @end        = false
    end

    # Gets a URL from the list
    #
    # TODO: handle non-UTF8 input
    def next_row
      # Get a CSV::Row object
      row = @csv.shift
      return row
    rescue EOFError
      @end = true
      return nil
    end

    def rewind
    end

    def at_end?
      @end
    end

    def close
      @h.close
    end
  end
  
end
