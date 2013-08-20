

#
# Scuttlebutt's main scraping engine
#
# Currently wrapped around selenium-webdrive
#
module Scuttlebutt

  # TODO (long term) Generalise this to support non-selenium things. 
  class Engine
  
    require 'selenium-webdriver'

    def initialize
      puts "New engine"
      @driver = Selenium::WebDriver.for :firefox  # TODO: make configurable
    end

    def close
      puts "Closing engine"
      @driver.quit
    end

  end


end
