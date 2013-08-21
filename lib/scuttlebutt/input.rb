# Scuttlebutt input library
#
# Currently supports only reading one-line-per-URL lists
#


module Scuttlebutt

  # Further input classes are likely...
  module Input

    require 'csv'

    class CSVSource

      # Default config used when opening CSVs
      CSV_CONFIG = { headers: true }

      attr_reader :max, :count

      def initialize(filename)
        @filename = filename

        raise "File not found: #{@filename}"    if !File.exist?(@filename)
        raise "File not readable: #{@filename}" if !File.readable?(@filename)

        # Count rows only if it's not a pipe or other io
        @max = count_rows if File.file?(@filename)
        @count = 0

        # Open file handle
        @csv        = CSV.open(@filename, 'r', CSV_CONFIG)

        # Not at end...
        @end        = false
      end

      # Gets a URL from the list
      #
      # TODO: handle non-UTF8 input
      def next_row
        # Get a CSV::Row object
        row = @csv.shift
        @count += 1
        return row
      rescue EOFError
        @end = true
        return nil
      end

      def at_end?
        @end
      end

      def close
        @csv.close
      end

    private

      # Count CSV rows in a file.
      def count_rows
        count = 0
        CSV.foreach(@filename, CSV_CONFIG) { count += 1 }
        return count
      end

    end
  

  end
end
