

module Scuttlebutt


  require 'scuttlebutt/compiler/interpreter'

  class VirtualMachine
    def initialize(data_src, code_class, engine)
      # Store the args
      @src      = data_src
      @cls      = code_class
      @engine   = engine

      # Progress
      @count    = 0
    end
    
    # Run over the input data, calling stuff as appropriate
    def run
      obj = @cls.new(@engine)

      ##= Script up region call.
      obj.system_up

      while(row = @src.next_row)
        @count += 1
        yield(@count, row) if block_given?

        ##= Row up region call
        obj.row_up


        ##= Row down region call
        obj.row_down

        puts "--> DATA -- #{obj.data}"

      end

      ##= Script down region call
      obj.system_down

      return @count
    end

    # TODO: thread safety for this one tiny count.
    def progress
      @count
    end

  end
end
