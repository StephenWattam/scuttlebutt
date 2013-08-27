

#
# Scuttlebutt's main scraping engine
#
# Currently wrapped around selenium-webdrive
#
module Scuttlebutt

  # TODO (long term) Generalise this to support non-selenium things. 
  class Engine
  
    require 'selenium-webdriver'

    TIMEOUT_PAGE_LOAD   = 60
    TIMEOUT_DOM_EDITS   = 0.2
    TIMEOUT_SCRIPT_EXEC = 60

    attr_reader :browser

    def initialize(browser = :firefox)
      @browser = browser.to_sym

      connect_driver
    end

    def close
      LOG.info "Shutting down browser engine..."
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


  private

    def connect_driver
      
      LOG.info "Starting driver for browser: #{browser}"
      @driver = Selenium::WebDriver.for(browser)  # TODO: make configurable

      @driver.manage.timeouts.implicit_wait   = TIMEOUT_DOM_EDITS
      @driver.manage.timeouts.page_load       = TIMEOUT_PAGE_LOAD
      @driver.manage.timeouts.script_timeout  = TIMEOUT_SCRIPT_EXEC
      # @driver.visible = false

    end

  end


end
