

module Scuttlebutt::Output

  require 'scuttlebutt/output'



  class CSVOutput < OutputMethod

    # Creates a new CachedCSVOutput that will output
    # to a given filename
    def initialize(filename, keys)
      @filename = filename

      raise "Output file already exists!" if File.exist?(filename)

      @keys = keys
      @row_cache = []

      @count = 0

      @csv = CSV.open(@filename, 'w')

    end

    # Estimate the amount of data unsynced
    def cached_data
      @row_cache.length
    end

    def row_count
      @row_cache.length
    end

    def start_row
      LOG.debug "Starting new row output cache."
      flush
    end

    def discard_row
      LOG.warn "Output system discarding #{@row_cache.length} data item[s] from a failed row."
      @row_cache = []
    end

    def finalise_row
      LOG.info "Finalising #{@row_cache.length} item[s] from a successful input row."
      flush
    end

    # Write output into the object
    def finalise(row)
      ordered_row = []
      @keys.each do |k| 
        ordered_row << row[k]
      end

      @row_cache << ordered_row 

      # keep count
      @count += 1
    end

    # Flush remaining output from cache
    def flush
      @row_cache.each { |row| @csv << row }
      @csv.flush
      @row_cache = []
    end

    # Close all resources
    def close
      @csv.close
    end
  end





  class CachedCSVOutput < OutputMethod

    # Creates a new CachedCSVOutput that will output
    # to a given filename
    def initialize(filename)
      @filename = filename

      raise "Output file already exists!" if File.exist?(filename)

      @keys = []
      @rows = []
      @row_cache = []

      @count = 0
    end


    def start_row
      LOG.debug "Starting new cache for output row"
      @row_cache = []
    end

    def discard_row
      LOG.warn "Output system discarding #{@row_cache.length} data item[s] from a failed row."
      @row_cache = []
    end

    def finalise_row
      LOG.info "Finalising #{@row_cache.length} item[s] from a successful input row."
      @rows += @row_cache
    end

    def row_count
      @row_cache.length
    end

    # Estimate the amount of data unsynced
    def cached_data
      @rows.length + @row_cache.length
    end

    # Write output into the object
    def finalise(row)
      @keys = (row.keys + @keys).uniq
      @row_cache << row

      # keep count
      @count += 1
    end

    # Flush remaining output from cache
    def flush 
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

    # Stub.
    def close
    end
  end

end
