

module Scuttlebutt::Output

  require 'scuttlebutt/output'

  class CachedCSVOutput < OutputMethod

    # Creates a new CachedCSVOutput that will output
    # to a given filename
    def initialize(filename)
      @filename = filename

      raise "Output file already exists!" if File.exist?(filename)

      @keys = []
      @rows = []

      @count = 0
    end

    # Estimate the amount of data unsynced
    def cached_data
      @rows.length
    end

    # Write output into the object
    def finalise(row)
      @keys = (row.keys + @keys).uniq
      @rows << row

      # keep count
      @count += 1
    end

    # Flush remaining output from cache
    def output
      CSV.open(@filename, 'w') do |csv|

        # Output header line
        csv << @keys

        # Output all the stored rows
        @rows.each do |row|

          # Build in-order row array
          out = []
          @keys.each { |k| out << row[k] }

          # Push to CSV
          csv << out

        end

      end
    end
  end

end
