

#
# Scuttlebutt's main scraping engine
#
# Currently wrapped around selenium-webdrive
#
module Scuttlebutt

  # TODO (long term) Generalise this to support non-selenium things. 
  class Engine
  
    require 'selenium-webdriver'

    TIMEOUT_PAGE_LOAD = 60
    TIMEOUT_DOM_EDITS = 0.2
    TIMEOUT_SCRIPT_EXEC = 60


    def initialize
      puts "New engine"
      @driver = Selenium::WebDriver.for :firefox  # TODO: make configurable

      @driver.manage.timeouts.implicit_wait   = TIMEOUT_DOM_EDITS
      @driver.manage.timeouts.page_load       = TIMEOUT_PAGE_LOAD
      @driver.manage.timeouts.script_timeout  = TIMEOUT_SCRIPT_EXEC
      # @driver.visible = false
    end

    def close
      puts "Closing engine"
      @driver.quit
    end

    # Pass calls through to the driver if unknown
    def method_missing(meth, *args, &block)
      if @driver.respond_to?(meth)
        if block
          @driver.send(meth, *args){ |*bargs| block.yield(*bargs) }
        else
          @driver.send(meth, *args)
        end
      else
        super
      end
    end

  end


end
