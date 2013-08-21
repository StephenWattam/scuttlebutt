

module Scuttlebutt::Interpreter::Time

  # Randomly wait up to n seconds if no delay given
  DEFAULT_MAX_DELAY = 5

  def self.delay(seconds)
    sleep(seconds.to_f)
  end

  def self.delay_rand(seconds = nil, max = nil)
    # Select a random delay
    seconds = (rand * DEFAULT_MAX_DELAY) unless seconds

    # Randomise between the two numbers
    if seconds && max and max > seconds
      seconds = (rand * (max - seconds)) + seconds
    end

    sleep(seconds.to_f)
  end

end
