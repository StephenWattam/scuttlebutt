

module Scuttlebutt::Interpreter::Interface


    # Print debug data to screen
    def self.debug(string)
      puts "*** #{Time.new} #{string.to_s}"
    end

end
